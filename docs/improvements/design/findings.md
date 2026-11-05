# Chosen Design Findings

**2. Don't let the system navigation bar cover the bottom of scrollable lists**

**Link:** https://flutterpro.design/details/md/safe-area-replacement

the last item of scrollable lists gets obscured by the system navigation bar. Leave space as tall as that bar at the end of the list so the last item has a breathing room against the bar.

**4. Match text selection to your app's colors**

**Link:** https://flutterpro.design/details/md/selection-color

`MaterialApp` applies default tinted colors for text selection in inputs. Match them to your brand colors instead.

**5. Load network images smoothly**

**Link:** https://flutterpro.design/details/md/smooth-image-loading

images in Flutter load with no transition, no placeholder and no failure state. They just pop in. Make it calmer: Show a plain grey box until each picture is ready and fade it in. If fails show a subtle broken image icon, never a technical message.

**8. Never show "null" on screen**

**Link:** https://flutterpro.design/details/md/never-show-null

when a string field comes back `null` or empty from the API and gets displayed directly, the user sees the word "null" or a blank spot on screen. A bad experience, and something they should never see. Instead, gate those values to show "-" or "N/A".

**10. Format numbers for user's locale**

**Link:** https://flutterpro.design/details/md/format-numbers-for-humans

a raw `1234567` is hard to read. Users expect numbers the way their region writes them: `1,234,567` in the US, `1.234.567` in Germany. Every count, price and big number should be displayed that way.

**12. Add haptic feedback to key moments**

**Link:** https://flutterpro.design/details/md/haptic-feedback

the app feels flat when taps and results happen in silence. A subtle haptic vibration on a tab switch, a successful submit or an error makes the app feel responsive in the hand.

**13. Use tabular figures for changing numbers**

**Link:** https://flutterpro.design/details/md/tabular-figures

digits have different widths in most fonts, so a timer or counter jumps around as it changes. Tabular figures make every digit the same width: numbers stay still and line up.

**15. Dismiss the keyboard when the user scrolls**

**Link:** https://flutterpro.design/details/md/dismiss-keyboard-on-scroll

the user finishes typing and scrolls to see the rest, but the keyboard stays covering half the screen. Scrolling means they're done with the field, so close it for them.

**16. Scroll to top when the current bottom nav item is tapped again**

**Link:** https://flutterpro.design/details/md/bottom-nav-reselect

tapping the bottom nav bar item you're already on should scroll that page to the top. It's muscle memory for native app users, so they'll expect it from your apps too.

**17. Show the app version in settings**

**Link:** https://flutterpro.design/details/md/show-app-version

when a user reports a bug, the first question is which version they're on, and the app has no place to answer it.

**20. Show scrollbars on vertical scrollables**

**Link:** https://flutterpro.design/details/md/scrollbars

a scrollbar shows the user where they are in the list and how much is left.

**21. Make the whole GestureDetector area tappable**

**Link:** https://flutterpro.design/details/md/gesture-detector-hit-area

by default `GestureDetector` only takes taps on what its child paints, so the padding and the gaps between an icon and a text do nothing. The user taps the row and misses. The whole box should take the tap.

**22. Format dates for user's locale**

**Link:** https://flutterpro.design/details/md/format-date-times

`2016-06-24 14:44:00.000` is what `DateTime` prints, and no user should read a date like that. Show `24 July 2016, 14:44` instead, in the user's language.

**27. Strip Material tap effects from custom designs**

**Link:** https://flutterpro.design/details/md/strip-material-tap-effects

Material widgets ripple and glow on tap by default, and in an app with a custom design language those effects clash with it.

**29. Unfocus the text field before opening a modal**

**Link:** https://flutterpro.design/details/md/unfocus-before-modal

opening a modal while a text field is focused brings the keyboard back when the modal closes, even though the user was done typing. Unfocus before opening and it stays away.

**30. Show a friendly view when a widget breaks**

**Link:** https://flutterpro.design/details/md/friendly-error-view

when a widget fails to build, users see an empty grey box in release. Show a friendly "Something went wrong" in the app's own colors instead.

**31. Format phone numbers**

**Link:** https://flutterpro.design/details/md/format-phone-numbers

a phone number shown or typed as one long run of digits is hard to read and easy to mistype. It should be formatted everywhere the user sees one, including while they type to a text field.

**32. Give every text field the right keyboard action**

**Link:** https://flutterpro.design/details/md/text-input-action

users should be able to fill a form and submit it with the keyboard's action key alone: it moves them to the next field, and on the last one, submits. No tapping each field by hand.

