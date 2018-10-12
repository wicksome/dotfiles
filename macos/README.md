# Customizing MacOS Environment.

## Change Appearance to Dark
![](https://user-images.githubusercontent.com/5036939/46842340-fafa8f00-cd81-11e8-9470-b496109d455a.png)
## Hide Siri in menu bar
![](https://user-images.githubusercontent.com/5036939/46842317-e3bba180-cd81-11e8-8374-43e3a3ac3c72.png)
## Change shortcut to Show Spotlight.
![](https://user-images.githubusercontent.com/5036939/46842334-f7ff9e80-cd81-11e8-83f0-9efcd0c3ad98.png)
## Change shortcut to Switch Input Source
![](https://user-images.githubusercontent.com/5036939/46842320-e7e7bf00-cd81-11e8-8cbb-c9e445866ceb.png)
## Change other shortcut
![](https://user-images.githubusercontent.com/5036939/46843053-d86a7500-cd85-11e8-91d2-8ef42d135702.png)
## Change Caps Lock to Control
![](https://user-images.githubusercontent.com/5036939/46842322-eae2af80-cd81-11e8-91c2-7c3ff2b382db.png)
## Change F1, F2, etc. keys to standared
![](https://user-images.githubusercontent.com/5036939/46843121-18315c80-cd86-11e8-94c4-ed10470ed146.png)
## Resizing the Dock
![](https://user-images.githubusercontent.com/5036939/46842330-f46c1780-cd81-11e8-8114-c77ab045c8c7.png)
OR
```
defaults write com.apple.dock tilesize -int 36
killall Dock
```

## Show Battery Percentage
![](https://user-images.githubusercontent.com/5036939/46842344-fe8e1600-cd81-11e8-91e0-ba87fb4136ed.png)
## Delete Guest
![](https://user-images.githubusercontent.com/5036939/46842347-00f07000-cd82-11e8-8df1-3940eb40b2b4.png)

## Remove all apps in Dock
```
defaults write com.apple.dock persistent-apps -array
killall Dock
```
