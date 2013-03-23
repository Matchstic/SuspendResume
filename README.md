**What is this?**

At it's heart, this tweak is designed to automatically lock an iPhone if it is put in a pocket without locking it first. However, it can also be used to lock the iPhone with a wave of your hand over the proximity sensor, to create a smart cover for iPhone, and many other uses.

**What hardware does it use?**

Only the proximity sensor, and any battery loss as a result of using this sensor is more than made up by that saved by locking the iPhone.

**Which devices does it support?**

Anything with a proximity sensor! So, all models of the iPhone, '2G' through to the current 5.

**Known Bugs**

- The device doesn't lock when in an application, only in SpringBoard
- When the tweak is turned off, proximity monitoring is still enabled
- Occaisonally, proximity monitoring is turned off, and a respring is required to re-enable it
- Calls are dropped/hung up in MobilePhone.app, and also in third-party apps such as CallBar, since the device is locked
- After a reboot or respring, the lockscreen accepts proximity events, and locks itself, sometimes casuing a respring

**TODO**
- Fix bugs!
- Add a menu under preferences where apps can be blacklisted from being locked
- Other cool stuff!

Hint: When using this to lock your iPhone with a hand gesture, don't forget to feel like a Jedi ;)

Created using <a href="https://github.com/kokoabim/iOSOpenDev">iOSOpenDev</a>.