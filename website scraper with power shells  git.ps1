#How to Scrape Page with Powershell
$creds = new-object System.Net.NetworkCredential(username,password)
$a = website http
$w = Invoke-WebRequest -Uri $a

# TypeName: Microsoft. power-Shell. Commands. HtmlWebResponseObject 
$w | Get-Member 

# HTML status 
$w.StatusCode

$w.AllElements.Count 
$w.Links.Count 

$w.RawContent 

$w.ParsedHtml

$w.AllElements | where tagname -EQ "P" | select innerText 

$w.AllElements | where tagname -EQ "H2" | select innerText 

$w.AllElements | where class -EQ "summary swap" | select outerText
