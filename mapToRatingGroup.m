function group = mapToRatingGroup(rawRating)
    % Step 1: Trim whitespace
    rating = strtrim(rawRating);

    % Step 2: Remove outer parentheses
    if length(rating) >= 2 && rating(1) == '(' && rating(end) == ')'
        rating = rating(2:end-1);
    end

    % Step 3: If starts with lowercase letter, assign NR
    if ~isempty(rating) && isstrprop(rating(1), 'lower')
        group = 'NR';
        return;
    end

    % Step 4: Convert to uppercase (safe since first char is not lowercase)
    rating = upper(rating);

    % Step 5: Group based on prefix
    if strncmp(rating, 'AAA', 3)
        group = 'AAA';
    elseif strncmp(rating, 'AA', 2)
        group = 'AA';
    elseif strncmp(rating, 'A', 1) && ~strncmp(rating, 'AA', 2)
        group = 'A';
    elseif strncmp(rating, 'BBB', 3)
        group = 'BBB';
    elseif strncmp(rating, 'BB', 2) && ~strncmp(rating, 'BBB', 3)
        group = 'BB';
    elseif strncmp(rating, 'B', 1) && ~strncmp(rating, 'BB', 2) && ~strncmp(rating, 'BBB', 3)
        group = 'B';
    else
        group = 'NR';
    end
end
