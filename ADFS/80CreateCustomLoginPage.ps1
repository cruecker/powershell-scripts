#Erstellen einen custom web theme
New-AdfsWebTheme –Name custom –SourceName default
mkdir c:\theme

#Export der onload.js für die Bearbeitung
Export-AdfsWebTheme –Name default –DirectoryPath c:\theme
#nun die onload.js erweitern mit (am Ende der Datei einfügen):

// Check if user is registered for Azure MFA or not.
if (document.getElementById('errorMessage').innerHTML.search("The selected authentication method is not available") ) { 
// Display message with registration link.
errorMessage.innerHTML = 'Before logging on, you must first enrol for Azure Multi-Factor Authentication. Please go to <a href="https://aka.ms/mfasetup">https://aka.ms/mfasetup</a> to register, and then try logging on again.'; }

#Custom Theme Updaten
Set-AdfsWebTheme -TargetName custom -AdditionalFileResource @{Uri=’/adfs/portal/script/onload.js’;path="c:\theme\script\onload.js"}

#Aktivieren des Custom Web Themes
Set-AdfsWebConfig -ActiveThemeName custom
