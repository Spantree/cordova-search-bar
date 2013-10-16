// Find the cordova reference used in the currently running app (differs based on version)
var cordovaRef =  window.cordova || window.Cordova || window.PhoneGap;

// Define our SeachBar Object
// You can call the functions within the SearchBar at any time by calling SearchBar.FUNCTION_NAME();
var SearchBar = {


    // show() - Used to initially display the search bar. Automatically adds an offset for iOS7 devices.
    show: function() {
        cordovaRef.exec(null, null, 'SearchBar', 'show', []);
    },
    
    // hide() - Used to remove the currently displaying search bar. Automatically adds an offset for iOS7 devices.
    hide: function() {
        cordovaRef.exec(null, null, 'SearchBar', 'hide', []);
    }
    
}

// Create Search event for callback
// To call the event from Objective C:
//  [self writeJavascript:@"cordova.fireDocumentEvent('searchEvent', {text:'TEXT_TO_SEND'})"];
function handleSearch(data) {
    alert("You searched: " + data.text);
}

document.addEventListener('searchEvent', handleSearch, true);