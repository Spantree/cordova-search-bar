cordova-search-bar
==================

A Cordova plugin to display a native SearchBar and send the search text back to the Cordova WebView.
Currently only includes the iOS plugin.

Installation
------------

Follow the **Cordova guide** on plugin installation
http://cordova.apache.org/blog/releases/2013/07/23/cordova-3

**or**

**Install Manually**  
1. Copy the SearchBar.h and SearchBar.m files into your XCode project <code>/Plugins</code> directory.  
2. Copy searchbar.js into your XCode project <code>/www</code> directory (can place anywhere in this directory, eg. a <code>www/js</code>).  
3. Add the following to the config.xml in your root XCode project directory:
        ````  
        <feature name="SearchBar">  
           <param name="ios-package" value="SearchBar" /> 
        </feature>
       ```  
4. Import searchbar.js wherever needed (path being wherever you placed the file in step 2).
