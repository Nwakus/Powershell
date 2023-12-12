#This gave the extraction of the table.schema from the select statement some data-sources was blank

# The directory to search 
$searchpath = 

# Regular expression to extract tables and joins
$tableJoinPattern = "FROM\s+([\w.]+)|JOIN\s+([\w.]+)"

# List all rdl files from the given search path recursively searching subfolders, store results into a variable
$files = Get-ChildItem $searchpath -Recurse -Filter "*.rdl" | Select-Object FullName, DirectoryName, Name

# Create an empty array to store the results
$results = @()

# Iterate over each found file
foreach ($file in $files) {
    $Directory = $file.DirectoryName
    $Name = $file.Name

    # Read and parse the XML content from the RDLC file
    $xmlContent = [xml](Get-Content $file.FullName)

    # Extract tables and joins from SQL queries in DataSets
    $tableNames = $xmlContent.Report.DataSets.DataSet | ForEach-Object {
        $dataSourceName = $_.DataSourceName
        $commandType = $_.Query.CommandType
        $commandText = $_.Query.CommandText

        if ($dataSourceName -eq $null) {
            $dataSourceName = ($xmlContent.Report.DataSources.DataSource | Where-Object { $_.Name -eq $_.Query.DataSourceName }).ConnectionProperties.ConnectString
        }

        if ($_.Query.Tables) {
            $tables = ($_.Query.Tables.ChildNodes | Where-Object { $_.Name -eq 'Table' }).InnerText -join ', '
        } else {
            $tableJoinMatches = [regex]::Matches($commandText, $tableJoinPattern)
            $tables = @()

            foreach ($match in $tableJoinMatches) {
                for ($i = 1; $i -lt $match.Groups.Count; $i++) {
                    $groupValue = $match.Groups[$i].Value
                    if ($groupValue -ne "") {
                        $tables += $groupValue
                    }
                }
            }

            $tables = $tables -join ', '
        }

        [PSCustomObject]@{
            Path           = $Directory
            File           = $Name
            DataSourceName = $dataSourceName
            CommandType    = $commandType
            CommandText    = $commandText
            Tables         = $tables
        }
    }

    # Add the result objects to the results array
    $results += $tableNames
}

# Export the results to a CSV file
$results | Export-Csv test5.csv -NoTypeInformation
==========================================================================================================
# The directory to search 
$searchpath = 

# List all rdl files    from the given search path recusrivley searching sub folders, store results into a variable
$files = gci $searchpath -recurse -filter "*.rdl" | SELECT FullName, DirectoryName, Name 

# for each of the found files pass the folder and file name  and the xml content
 # in the xml content navigate to the the DataSets Element
  # for each query retrieve the Report directory , File Name, DataSource Name, Command Type, Command Text output thwese to a csv file
$files | % {$Directory = $_.DirectoryName; $Name = $_.Name; [xml](gc $_.FullName)}| % {$_.Report.DataSets}| % {$_.DataSet.Query} | SELECT  @{N="Path";E={$Directory}}, @{N="File";E={$Name}}, DataSourceName, CommandType, CommandText | Export-Csv Test6.csv -notype
              
 
================================================================================================================
# SQL query example
$sqlQuery = @"
SELECT  s.name SchemaName
, SUM(isDocumented) isDocumented
, COUNT(C.name) /*- SUM(td*1)*/ col_cnt
, SUM(td*1) todelete
, COUNT(C.name) - SUM(isDocumented)  /*- SUM(td*1)*/ miss_pi_cnt
, SUM(CASE WHEN pd.pi_id_num > 0 /*AND td= 0 */THEN 1 ELSE 0 END) isPI
FROM sys.objects o WITH(NOLOCK) 
INNER JOIN sys.schemas s WITH(NOLOCK) ON s.schema_id = o.schema_id
INNER JOIN sys.columns c With(nolock) ON c.object_id = o.object_id
LEFT JOIN sys.extended_properties ep WITH(NOLOCK) ON ep.major_id = c.object_id and ep.minor_id = c.column_id AND EP.name = 'CPP_PI_ELEMENT'
LEFT JOIN metadata.cpp_pi_elements_def_todelete pd WITH(NOLOCK) ON pd.Id = ep.value 
LEFT JOIN sys.extended_properties tep WITH(NOLOCK) ON tep.major_id = c.object_id and tep.minor_id = 0 AND tep.name = 'CPP_TODELETE'
OUTER APPLY ( VALUES (CONVERT(BIT,CASE WHEN 'CPP_TODELETE' = tep.name then 1 else 0 END ))) Expr1(td)
OUTER APPLY ( VALUES (
		CASE WHEN ep.value is not null then /*~td * */ 1 ELSE 0  END 
)) Expr2 (isDocumented)
WHERE o.type = 'U'
GROUP BY   o.schema_id , s.name
ORDER BY  COUNT(C.name) - SUM(td*1) DESC
"@

# Regular expression to extract tables and joins with schema
$tableJoinPattern = "FROM\s+([\w.]+)|JOIN\s+([\w.]+)"

# Find matches using the regular expression
$tableJoinMatches = [regex]::Matches($sqlQuery, $tableJoinPattern)

# Extract tables and joins with schema from matches
$tables = @()

foreach ($match in $tableJoinMatches) {
    # Iterate through capturing groups and add non-empty values to the $tables array
    for ($i = 1; $i -lt $match.Groups.Count; $i++) {
        $groupValue = $match.Groups[$i].Value
        if ($groupValue -ne "") {
            $tables += $groupValue
        }
    }
}

# Display the extracted tables
Write-Host "Tables: $($tables -join ', ')"
