# Neovim mac notifications

1. Open the Script Editor and paste the contents of `notification.scpt` into it.
2. Export it as an 'Application' leaving all the checkboxes unchecked.
3. Right-click the new app and open its contents.
4. Replace the `applet.icns` icon file with the icon in `resources/neovim.icns`.
5. Update the value of the `CFBundleIconFile` key in the `Info.plist` file to 'neovim'.
6. Run `touch` on the app which should refresh the icon cache and make the icon
   appear. If not, you may have to restart your mac.
7. Once you run the app you will be prompted to allow it to send notifications.

The app takes three arguments: A message, a title, and a sound name where the
latter is optional. Using `osacompile` does not seem to work and produces an
app that does not show anything.

Examples of invocation:

```shell
> open /Applications/NeovimNotification.app --args "message" "title"
> open /Applications/NeovimNotification.app --args "message" "title" "Sorumi"
```
