**What is this?**

At it's heart, this tweak is designed to automatically lock an iPhone if it is put in a pocket without locking it first. However, it can also be used to lock the iPhone with a wave of your hand over the proximity sensor, to create a smart cover for iPhone, and many other uses. 

**What hardware does it use?**

Only the proximity sensor, and any battery loss as a result of using this sensor is more than made up by that saved by locking the iPhone.

**Which devices does it support?**

Anything with a proximity sensor! So, all models of the iPhone, '2G' through to the current 5.

**Known Bugs**

- There is no locking in the camera if it is launched from the lockscreen
- The UI freezes when getting second proximity value, need to do this on a separate thread
- The second proximity value always evaluates to yes - need a way of getting second proximity value, UIDevice's proximityState always returns NO?
- Proximity monitoring is turned off after a phone call, and a toggle on/off from preferences is required to re-enable it
- After a reboot or respring, the lockscreen accepts proximity events, and locks itself, casuing a respring - could be unrelated to tweak, need testers to confirm
- App blacklisting is not fully functional

Email me at mclarke0805@gmail.com if you find any more

**TODO**

- Fix bugs!
- Add a menu under preferences where apps can be blacklisted from being locked
- Other cool stuff!

Hint: When using this to lock your iPhone with a hand gesture, don't forget to feel like a Jedi ;)

Created using <a href="https://github.com/kokoabim/iOSOpenDev">iOSOpenDev</a>.
