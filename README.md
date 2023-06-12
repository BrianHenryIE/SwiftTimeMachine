# Swift Time Machine

Parses Time Machine logs and `tmutil` output. The goal is to automatically unmount USB drives after backups complete: [BrianHenryIE/UnmountVolumeAfterTimeMachine](https://github.com/BrianHenryIE/UnmountVolumeAfterTimeMachine)

> $ /usr/bin/tmutil 

> $ /usr/bin/log stream --predicate 'subsystem == "com.apple.TimeMachine"' --info


```swift
let tmUtil = TmUtil()
// Parses `tmutil destinationinfo`
let destinationInfo = tmUtil.destinationInfo()
if let volume = destinationInfo?.destinations.first?.mountPoint {
    print("Time machine drive mounted at: \(volume)")
}
```

```swift
let tmUtil = TmUtil()
// Parses `tmutil status`
let status = tmUtil.status()
if let running = status?.running {
    print("Time machine is\(running ? "" : " not") currently running.")
}
```

```swift
TimeMachineLog.shared.addObserver(
                self,
                selector: #selector(unmountVolume),
                name: Notification.Name.TimeMachineLogAfterCompletedBackup,
                object: nil
        )
```

## Swift Package Manager

```
.package( url: "https://github.com/BrianHenryIE/SwiftTimeMachine", branch: "master" )
```

You might want to pin that to a commit in case I change things. I don't write Swift in my day job (but this was mostly test driven).

## Notes

Sometimes does thinning
```
Completed backup: 2022-05-21-120849
Mountpoint '/Volumes/8tb' is still valid
Thinning 3 backups using age-based thinning, expected free space: 678.7 GB actual free space: 678.7 GB trigger 50 GB thin 83.33 GB dates: (
 "2022-05-18-145930",
 "2022-05-18-155714",
 "2022-05-18-165813"
)
Mountpoint '/Volumes/8tb' is still valid
```

Doesn't always do thinning
```
Completed backup: 2022-05-21-175757
Mountpoint '/Volumes/8tb' is still valid
Mountpoint '/Volumes/8tb' is still valid
```


* https://stackoverflow.com/questions/54927655/event-notifications-in-macos

This project currently uses [Swift OS Log Stream](https://github.com/BrianHenryIE/BHSwiftOSLogStream) which `tail`s and parses `/usr/bin/log`. Instead of that, it should use [OSLogStore](https://developer.apple.com/documentation/oslog/oslogstore), particularly because it currently needs admin access, or better yet, DistributedNotificationCenter.

> DistributedNotificationCenter.default().addObserver(self, selector: #selector(handleNotifications), name: nil, object: nil)
>
> "You have to filter the notifications related to Time Machine. You can also observe specific notifications via the name parameter"

## Links

* https://fig.io/manual/tmutil/

`tmutil` documentation. There might be better official documentation elsewhere, but this is where I learned about the `-X` flag to output the response as a plist/XML.

* https://eclecticlight.co/2019/12/04/time-machine-2-what-it-writes-in-the-log/

Deep dive into Time Machine logs.

* https://github.com/0xdevalias/devalias.net/issues/89

More detailed Time Machine notes

* https://github.com/homebysix/misc/blob/main/2015-03-25%20Time%20Machine%20Deep%20Dive/README.md

Discussion of Time Machine with many `tmutil` command examples.

## Other Software

* [textbar-timemachine](https://github.com/tjluoma/textbar-timemachine)
* [tmutil-status](https://github.com/jsejcksn/tmutil-status)
* [TMBuddy](https://github.com/grigorye/TMBuddy)
* [Time Machine Snapshot Mounter](https://github.com/glessard/tmsm)
* [samuelmeuli/tmignore](https://github.com/samuelmeuli/tmignore)
* [Time Machine helper](https://github.com/tdilauro/tm)
* [Growl Time Machine Monitor](https://github.com/growl/growl/blob/master/Extras/HardwareGrowler/TimeMachineMonitor/HWGrowlTimeMachineMonitor.m) (remember Growl!?)

