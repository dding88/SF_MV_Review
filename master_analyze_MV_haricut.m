%3 month window
startingColName = 'x3_30_2022';
riskHorizon = 3;
currency = 'USD';
assetType = 'CDO';
analyze_MV_haircut(assetType, startingColName, riskHorizon,currency);
clear;

startingColName = 'x3_30_2022';
riskHorizon = 3;
currency = 'USD';
assetType = 'ABS';
analyze_MV_haircut(assetType, startingColName, riskHorizon,currency);
clear;

startingColName = 'x3_30_2022';
riskHorizon = 3;
currency = 'USD';
assetType = 'CMBS';
analyze_MV_haircut(assetType, startingColName, riskHorizon,currency);
clear;

startingColName = 'x3_30_2022';
riskHorizon = 3;
currency = 'USD';
assetType = 'RMBS';
analyze_MV_haircut(assetType, startingColName, riskHorizon,currency);


%12 month window
startingColName = 'x3_30_2022';
riskHorizon = 12;
currency = 'USD';
assetType = 'CDO';
analyze_MV_haircut(assetType, startingColName, riskHorizon,currency);
clear;

startingColName = 'x3_30_2022';
riskHorizon = 12;
currency = 'USD';
assetType = 'ABS';
analyze_MV_haircut(assetType, startingColName, riskHorizon,currency);
clear;

startingColName = 'x3_30_2022';
riskHorizon = 12;
currency = 'USD';
assetType = 'CMBS';
analyze_MV_haircut(assetType, startingColName, riskHorizon,currency);
clear;

startingColName = 'x3_30_2022';
riskHorizon = 12;
currency = 'USD';
assetType = 'RMBS';
analyze_MV_haircut(assetType, startingColName, riskHorizon,currency);