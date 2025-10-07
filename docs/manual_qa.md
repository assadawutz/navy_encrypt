# Manual QA - Save Dialog Cancellation

## Scenario: Cancel save dialogs
1. Launch the app and navigate to the result page with a generated file ready to save.
2. Tap the **Save** button and choose the "โฟลเดอร์อื่นๆ (เลือกจาก System Dialog)" option.
3. When the system directory picker appears, press **Cancel**.
4. Confirm that no error dialog or toast appears and the app remains on the result page.
5. Repeat steps 2-4 using the Windows "Save As" dialog (e.g., on Windows build) and cancel the dialog.
6. Verify again that no error message is shown and the user can continue interacting with the page.

## Expected result
Canceling either dialog closes the picker without surfacing an error dialog or toast, and the save state resets so another save attempt can be made.
