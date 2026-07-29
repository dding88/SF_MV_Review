sheet.name = 'US ABS History';
assetType = 'US_ABS';

data = readtable('Market Price Criteria Project.xlsx', 'Sheet', sheet.name);
dealinfo = readtable('IDF_rating_info.xlsx', 'Sheet', 'IDF_rating_info');

%% Step 2: Add 'FoundInDealinfo' column
new_ISIN = data.ISIN;
orig_ISIN = dealinfo.ISINS;
isMatch = ismember(cellstr(new_ISIN), cellstr(orig_ISIN));
matchFlag = repmat('N', height(data), 1);
matchFlag(isMatch) = 'Y';
data.FoundInDealinfo = matchFlag;
oldVarNames = data.Properties.VariableNames;
newOrder = [{'FoundInDealinfo'}, oldVarNames(1:end-1)];
data = data(:, newOrder);

%% Step 3: Extract pricing data
priceStartCol = 'x1_2_2017';  % adjust as needed
priceStartCol = find(strcmp(data.Properties.VariableNames, priceStartCol));
priceData = data{:, priceStartCol:end};

%% Step 4: Map ratings into groups
groupNames = {'AAA', 'AA', 'A', 'BBB', 'BB', 'B', 'NR'};
ratingGroups = cell(height(data), 1);

for i = 1:height(data)
    r = data.CurrentRating{i};
    if strcmp(r, 'AAA')
        ratingGroups{i} = 'AAA';
    elseif ~isempty(regexp(r, '^AA', 'once'))
        ratingGroups{i} = 'AA';
    elseif ~isempty(regexp(r, '^A', 'once'))
        ratingGroups{i} = 'A';
    elseif ~isempty(regexp(r, '^BBB', 'once'))
        ratingGroups{i} = 'BBB';
    elseif ~isempty(regexp(r, '^BB', 'once'))
        ratingGroups{i} = 'BB';
    elseif ~isempty(regexp(r, '^B', 'once'))
        ratingGroups{i} = 'B';
    else
        ratingGroups{i} = 'NR';
    end
end
data.RatingGroup = ratingGroups;

%% Step 5: Compute changes and summary
allChanges = cell(length(groupNames), 1);
totalCount = zeros(1, length(groupNames));
yesCount   = zeros(1, length(groupNames));
maxLen = 0;

for i = 1:length(groupNames)
    grp = groupNames{i};
    idx = strcmp(data.RatingGroup, grp);
    ratingPrices = priceData(idx, :);

    totalCount(i) = sum(idx);
    yesFlag = strcmp(cellstr(data.FoundInDealinfo), 'Y');
    yesCount(i) = sum(idx & yesFlag);

    changes = [];
    for j = 1:size(ratingPrices, 1)
        prices = ratingPrices(j, :);
        if all(isnan(prices)) || all(prices == 0)
            continue;
        end
        pctChange = (prices(2:end) - prices(1:end-1)) ./ prices(1:end-1);
        changes = [changes; pctChange(:)];
    end

    allChanges{i} = changes;
    maxLen = max(maxLen, length(changes));
end

%% Step 6: Build result table
result = table();
colNames = cell(1, length(groupNames));

for i = 1:length(groupNames)
    col = allChanges{i};
    if length(col) < maxLen
        col(end+1:maxLen, 1) = NaN;
    end
    colName = sprintf('col%d', i);
    result.(colName) = col;
    colNames{i} = colName;
end

row1 = array2table(totalCount, 'VariableNames', colNames);
row2 = array2table(yesCount, 'VariableNames', colNames);
result = [row1; row2; result];

%% Step 7: Add rating labels and build display matrix
resultData = [groupNames; num2cell(table2array(result))];
rowLabels = {'RatingLabel', 'TotalCount', 'YesCount'};
for q = 1:(size(resultData,1) - length(rowLabels))
    rowLabels{end+1} = sprintf('Row%d', q+2);
end
resultData = [rowLabels(:), resultData];

%% Step 8: Compute quantiles
numericPart = resultData(4:end, 2:end);   % rows 4+ and columns 2+
numericMatrix = cell2mat(numericPart);
qVals = [0, 0.005,0.01, 0.05, 0.1, 0.15, 0.25, 0.5, 0.75, 0.85, 0.9, 0.95, 0.99, 1];
numQuantiles = length(qVals);
quantileMatrix = zeros(numQuantiles, size(numericMatrix, 2));

for i = 1:size(numericMatrix, 2)
    dataCol = numericMatrix(:, i);
    qResult = quantile(dataCol, qVals);
    quantileMatrix(:, i) = qResult(:);
end

summary1 = num2cell(table2array(result(1, :)));  % TotalCount
summary2 = num2cell(table2array(result(2, :)));  % YesCount
quantileCells = num2cell(quantileMatrix);

quantileLabels = cell(numQuantiles, 1);
for i = 1:numQuantiles
    quantileLabels{i} = sprintf('Quantile_%g', qVals(i)*100);
    quantileLabels{i} = strrep(quantileLabels{i}, '.', '_');
end

finalData = [
    groupNames;     % row 1: rating labels
    summary1;       % row 2: total count
    summary2;       % row 3: yes count
    quantileCells   % rows 4+: quantiles
];

rowLabels = [{'RatingLabel'}; {'TotalCount'}; {'YesCount'}; quantileLabels];
finalData = [rowLabels, finalData];

%% Step 9: Export
output_filename = ['final_quantile_output_' assetType '-grouping-' datestr(now, 'yyyymmdd') '.xlsx'];
xlswrite(output_filename, finalData);