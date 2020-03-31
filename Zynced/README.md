## Current Problem:

_Description_: Clicking on "Save" when there are no changes, creates a new instance of SFTPConnection, which does NOT create a new Keychain item, because it already exists (because nothing changes). Then the program realizes, that were no changes made and releases the SFTPConnection instance that was created. This will remove the Keychain Item.

_Possible Solutions_:
* check if there were changes made without creating a new instance
* Save a retain count in the Keychain item, so that creating instances with the same Keychain Items increases the retain count and removing the Keychain item on deinit will only happen, if the retain count is 0 (this needs to be done in BoteCore)


## Todo:

### BoteCore:
#### Urgent:
- [ ] Sync manually (also on startup to check if everything is up-to-date). Maybe find a better solution than just removing everything and uploading everything again
- [ ] Divide SFTP into SFTPKeyConnection and SFTPPasswordConnection
- [ ] Implement more Transfer Handlers (AWS, WebDAV, GoogleDrive, FTP)

#### Later:


### Zynced:
#### Urgent:
- [ ] Add explanations for Status Indicator in UI (besides tooltips)
- [ ] Saved Item with no password &rarr add password &rarr save &rarr fails because no Keychain Item was initialy created
- [ ] Coordinate upload of big files (async), maybe with upload indicator
- [ ] Check what happens, when only password or path was changed, because the keychain item (search properties) don't change

#### Later
- [ ] Fix UITests



## UI Test Cases

* Select same connection in dropdown again and check if the fields were emptyed or stayed the same
* Open `unsavedChanges` dialogue, when Connection is beining changed but
