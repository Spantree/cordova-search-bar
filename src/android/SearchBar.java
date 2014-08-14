package net.spantree.searchbar;

import android.content.Context;
import android.util.TypedValue;
import android.view.KeyEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.*;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

/**
 * Spantree SearchBar Plugin.
 *
 * Android equivalent of iOS UISearchBar widget.
 * Allows for use of native components for consuming user input.
 *
 * @author alliecurry
 * @since 2.0
 */
public class SearchBar extends CordovaPlugin implements TextView.OnEditorActionListener {
    private static final String SEARCH_EVENT = "searchEvent";
    private static final String ACTION_SHOW = "show";
    private static final String ACTION_HIDE = "hide";

    private SearchView searchView;

    /**
     * Executes the request and returns PluginResult.
     *
     * @param action            The action to execute.
     * @param args              JSONArray of arguments for the plugin.
     * @param callbackContext   The callback context used when calling back into JavaScript.
     * @return                  True when the action was valid, false otherwise.
     */
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equalsIgnoreCase(ACTION_SHOW)) {
            // Show the search bar
            showSearchBar();
        } else if (action.equalsIgnoreCase(ACTION_HIDE)) {
            // Hide the search bar
            hideSearchBar();
        } else {
            // Unknown action
            return false;
        }
        callbackContext.success();
        return true;
    }

    private void initView() {
        searchView = new SearchView(cordova.getActivity());
        searchView.getInput().setOnEditorActionListener(this);
        searchView.getSearchButton().setOnClickListener(onSearchClick);
        overlayView(searchView);
    }

    /** The given View will be overlap on top of the local WebView. */
    private void overlayView(final View view) {
        RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.WRAP_CONTENT,
                RelativeLayout.LayoutParams.WRAP_CONTENT);
        params.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        webView.addView(view, params);
        view.bringToFront();
    }

    private void showSearchBar() {
        if (searchView == null) {
            initView();
        }
    }

    private void hideSearchBar() {


    }

    /** Method called when users requests to send a search.c*/
    private void onSearchAction() {

    }

    /** Sends the given search term to the Cordova WebView. */
    private void search(final String query) {
        webView.loadUrl(String.format("javascript:cordova.fireDocumentEvent('%s', {text:'%s'});", SEARCH_EVENT, query));
    }

    /** Attempts to close the Android Soft Keyboard. */
    private void closeKeyboard() {
        if (searchView == null) {
            return;
        }

        InputMethodManager imm = (InputMethodManager) cordova.getActivity()
                .getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(searchView.getInput().getWindowToken(), 0);
    }

    private View.OnClickListener onSearchClick = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            search(searchView.getInputText());
            closeKeyboard();
        }
    };

    /** Handles key events from the soft keyboard. */
    @Override
    public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
        final int action = event.getAction();
        if (action == KeyEvent.KEYCODE_SEARCH || action == KeyEvent.KEYCODE_ENTER) {
            search(searchView.getInputText());
            closeKeyboard();
            return true;
        }
        return false;
    }

    /** Custom Widget for mimicking the iOS UISearchBar. */
    private static class SearchView extends LinearLayout {
        private static final int SEARCH_ICON = android.R.drawable.ic_menu_search;
        private static final int BACKGROUND_COLOR = android.R.color.holo_purple;
        private static final int PADDING_DP = 20;
        private EditText input;
        private ImageButton searchButton;

        public SearchView(Context context) {
            super(context);
            initView();
            initChildViews(context);
        }

        /** Initializes default layout parameters and basic appearance. */
        private void initView() {
            final int padding = (int) dpToPx(PADDING_DP);
            setPadding(padding, padding, padding, padding);
            setOrientation(HORIZONTAL);
            setBackgroundColor(getResources().getColor(BACKGROUND_COLOR));
        }

        /** Initializes default child Views. */
        private void initChildViews(final Context context) {
            input = new EditText(context);
            searchButton = new ImageButton(context);
            searchButton.setImageDrawable(getResources().getDrawable(SEARCH_ICON));
            addView(input);
            addView(searchButton);
        }

        /** @return String representation of the current user input. */
        public String getInputText() {
            return input.getText().toString();
        }

        /** @return the local EditText child View. */
        public EditText getInput() {
            return input;
        }

        /** @return the local ImageButton child View . */
        public ImageButton getSearchButton() {
            return searchButton;
        }

        /** @return the given density-pixel unit in exact pixels. */
        private float dpToPx(final int dp) {
            return TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp, getResources().getDisplayMetrics());
        }
    }
}
