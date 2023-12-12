# Install Selenium module if not installed 
if (-not (Get-Module -Name Selenium -ListAvailable)) { Install-Module -Name Selenium -Force -AllowClobber }
 
# Import Selenium module 
Import-Module Selenium 

# Set the path to the Microsoft Edge WebDriver (replace with your actual path) 
$driverPath = "C:\Path\To\Your\MicrosoftWebDriver.exe" 

# Start the Selenium WebDriver for Microsoft Edge 
$driver = Start-SeEdge -DriverExecutablePath $driverPath 

# Navigate to the website 
$driver.Navigate().GoToUrl("https://example.com") 

# Find the dropdown element by its ID (replace 'dropdownId' with the actual ID) 
$dropdown = $driver.FindElementById("dropdownId") 

# Perform actions on the dropdown (e.g., select an option by value) 
$dropdown.SelectByValue("optionValue") 

# Close the browser $driver.Quit()