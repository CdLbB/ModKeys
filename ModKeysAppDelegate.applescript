--
--  ModKeysAppDelegate.applescript
--  ModKeys
--
--  Created by Eric Nitardy on 11/30/10.
--  Copyright 2010 University of Washington. All rights reserved.
--


property BitCalculations : class "BitCalculations"
property GlobalMonitor : class "GlobalMonitor"
property MyNSEvent : class "MyNSEvent"

property NSEvent : class "NSEvent"



script ModKeysAppDelegate
	property parent : class "NSObject"
	
	-------Script Variables-------	
	property QCAppName : "Axiotron Quickclicks"
	property QCWindowName : "Axiotron Quickclicks"
	property PenTabletDriverName : "PenTabletDriver"
	
	property shftBitMask : (2 ^ 17) as integer -- NSShiftKeyMask
	property ctlBitMask : (2 ^ 18) as integer -- NSControlKeyMask
	property optBitMask : (2 ^ 19) as integer -- NSAlternateKeyMask
	property cmdBitMask : (2 ^ 20) as integer -- NSCommandKeyMask
	
	property nextEventMask : (2 ^ 2) as integer --NSEventTypeMask for next event monitor: NSLeftMouseUp
	property buttonFlagMask : missing value -- reflecting the state of the modifier buttons 
	property windowIsMoving : false -- A temporary flag to indicate when the window is moving: see on windowDidMove_(aNotification)
	
	property flagChangeMonitor : missing value -- reference to flagChangeMonitor allowing removal
	property nextEventMonitor : missing value -- reference to nextEventMonitor allowing removal
	
	------- Properties bound to button states -------
	property modKeyLockOn : 0
	property cmdButtonValue : missing value
	property optButtonValue : missing value
	property ctlButtonValue : missing value
	property shftButtonValue : missing value
	
	------- Reference to window -------
	property keyPanel : missing value
	
	on testQuickclicksAndAssitiveEnabled() -- Error for no Quickclicks or for assistive devices disabled.
		try
			tell application QCAppName to launch
			tell application "System Events"
				tell process QCAppName
					get every UI element
				end tell
			end tell
		on error errTxt number errNum --(*Access for assistive devices is disabled.*) (*System Events got an error: Can’t get process "Axiotron Quickclicks".*) Both with error number: -1728 
			tell application "System Events"
				activate
				if errTxt is "Access for assistive devices is disabled." then
					display alert "Access for assistive devices is disabled." message "Access for assistive devices must be enabled for this application to function properly." & return & return & "Please check the box near the bottom of the \"Universal Access\" preferences panel. Then re-launch this application." as warning
				else
					display alert "Application " & "\"" & QCAppName & "\"" & " not present." message "This application requires " & QCAppName & " to function properly." as warning
				end if
			end tell
			current application's NSApp's terminate_(me) --Quit
		end try
	end testQuickclicksAndAssitiveEnabled
	
	------- One Modifier button pushed, click one mod key in Quickclicks to reflect that -------
	on changeModKey_keyMask_toState_(keyChar, keyMask, senderState)
		set newModMask to (MyNSEvent's modifierFlags) as integer
		log newModMask
		if buttonFlagMask = newModMask then return 0 -- no changes needed
		
		GlobalMonitor's removeMonitor_(flagChangeMonitor) --stop monitor to keep it from changing stuff while we click a mod key in Quickclicks
		
		tell application QCAppName -- record QC's bounds and visibility then move to lower corner and make visible
			set qcVisible to visible of window QCWindowName
			set qcBounds to bounds of window QCWindowName
			if qcVisible is false then
				set qcSizeX to (item 3 of qcBounds) - (item 1 of qcBounds)
				set qcSizeY to (item 4 of qcBounds) - (item 2 of qcBounds)
				set bounds of window QCWindowName to {0, 800, 0 + qcSizeX, 800 + qcSizeY}
				set visible of window QCWindowName to true
			end if
		end tell
		
		toggleQCKey_(keyChar) --click a key
		
		------ Sometimes fails, so repeat up to 3 times with increasing delays ------
		do shell script "sleep 0.3"
		set newModMask to (NSEvent's modifierFlags) as integer
		set keyBitValue to (BitCalculations's andBitsOf_with_(newModMask, keyMask) as integer ≠ 0) as integer
		if keyBitValue ≠ senderState then
			log "2nd try"
			log senderState
			log keyBitValue
			toggleQCKey_(keyChar)
			
			do shell script "sleep 1"
			set newModMask to (NSEvent's modifierFlags) as integer
			set keyBitValue to (BitCalculations's andBitsOf_with_(newModMask, keyMask) as integer ≠ 0) as integer
			if keyBitValue ≠ senderState then
				log "3rd try"
				log senderState
				log keyBitValue
				do shell script "sleep 1"
				toggleQCKey_(keyChar)
				
			end if
		end if
		
		--Reinstate Monitor--
		set flagChangeMonitor to GlobalMonitor's monitorEvery_performSelector_target_(current application's NSFlagsChangedMask, "modifierFlagsChanged:", me)
		
		---- Restore QC's bounds and visibility ----
		if qcVisible is false then
			tell application QCAppName
				set visible of window QCWindowName to qcVisible
				set bounds of window QCWindowName to qcBounds
			end tell
		end if
		
		---- Test to see if we succeeded in changing the modifier flag, if not return a 1 ----
		set newModMask to (NSEvent's modifierFlags) as integer
		set keyBitValue to (BitCalculations's andBitsOf_with_(newModMask, shftBitMask) as integer ≠ 0) as integer
		if keyBitValue ≠ senderState then return 1
		
		return 0
	end changeModKey_keyMask_toState_
	
	---- Click on QC modifier key ----
	on toggleQCKey_(keyChar)
		tell application "System Events"
			tell process QCAppName -- Determine click location
				set buttonPosition to position of button keyChar of window QCWindowName
				set buttonPositionX to item 1 of buttonPosition
				set buttonPositionY to item 2 of buttonPosition
				set buttonSize to size of button keyChar of window QCWindowName
				set buttonSizeX to ((item 1 of buttonSize) / 2) as integer
				set buttonSizeY to ((item 2 of buttonSize) / 2) as integer
				set xPositionS to buttonPositionX + buttonSizeX
				set yPositionS to buttonPositionY + buttonSizeY
			end tell
		end tell
		
		MyNSEvent's clickAtLocation_({x:xPositionS, y:yPositionS})
	end toggleQCKey_
	
	---- Change buttonFlagMask to reflect setting key: keyMask to senderState ----
	on changeButtonFlagMask(keyMask, senderState)
		if senderState is 1 then
			set buttonFlagMask to (BitCalculations's orBitsOf_with_(buttonFlagMask, keyMask)) as integer
		else
			set buttonFlagMask to (BitCalculations's deleteBitsOf_using_(buttonFlagMask, keyMask)) as integer
		end if
	end changeButtonFlagMask
	
	----------------------- Begin Modifier Keys ------------------------
	----------------------- Linked to UI buttons ----------------------	
	on commandKey_(sender)
		if nextEventMonitor is not missing value then
			GlobalMonitor's removeMonitor_(nextEventMonitor)
			set nextEventMonitor to missing value
		end if
		
		changeButtonFlagMask(cmdBitMask, cmdButtonValue as integer)
		set theResult to changeModKey_keyMask_toState_("⌘", cmdBitMask, cmdButtonValue as integer)
		
		if modKeyLockOn as integer is 0 and buttonFlagMask ≠ 0 and nextEventMonitor is missing value then
			set nextEventMonitor to GlobalMonitor's monitorNext_performSelector_target_(nextEventMask, "clearModButtons:", me)
		end if
	end commandKey_
	
	on optionKey_(sender)
		if nextEventMonitor is not missing value then
			GlobalMonitor's removeMonitor_(nextEventMonitor)
			set nextEventMonitor to missing value
		end if
		
		changeButtonFlagMask(optBitMask, optButtonValue as integer)
		set theResult to changeModKey_keyMask_toState_("⌥", optBitMask, optButtonValue as integer)
		
		if modKeyLockOn as integer is 0 and buttonFlagMask ≠ 0 and nextEventMonitor is missing value then
			set nextEventMonitor to GlobalMonitor's monitorNext_performSelector_target_(nextEventMask, "clearModButtons:", me)
		end if
	end optionKey_
	
	on controlKey_(sender)
		if nextEventMonitor is not missing value then
			GlobalMonitor's removeMonitor_(nextEventMonitor)
			set nextEventMonitor to missing value
		end if
		
		changeButtonFlagMask(ctlBitMask, ctlButtonValue as integer)
		set theResult to changeModKey_keyMask_toState_("⌃", ctlBitMask, ctlButtonValue as integer)
		
		if modKeyLockOn as integer is 0 and buttonFlagMask ≠ 0 and nextEventMonitor is missing value then
			set nextEventMonitor to GlobalMonitor's monitorNext_performSelector_target_(nextEventMask, "clearModButtons:", me)
		end if
	end controlKey_
	
	on shiftKey_(sender)
		if nextEventMonitor is not missing value then
			GlobalMonitor's removeMonitor_(nextEventMonitor)
			set nextEventMonitor to missing value
		end if
		
		changeButtonFlagMask(shftBitMask, shftButtonValue as integer)
		set theResult to changeModKey_keyMask_toState_("⇧", shftBitMask, shftButtonValue as integer)
		
		if modKeyLockOn as boolean is false and buttonFlagMask ≠ 0 and nextEventMonitor is missing value then
			set nextEventMonitor to GlobalMonitor's monitorNext_performSelector_target_(nextEventMask, "clearModButtons:", me)
		end if
	end shiftKey_
	-------------------------------------------------------------------------
	
	----------------------- Modifier Lock Key ----------------------------
	----------------------- Linked to UI button -------------------------
	on lockButton_(sender)
		if modKeyLockOn as boolean is true then -- remove detect next NSLeftMouseUp
			GlobalMonitor's removeMonitor_(nextEventMonitor)
			set nextEventMonitor to missing value
		else
			if buttonFlagMask ≠ 0 and nextEventMonitor is missing value then -- enable detect next NSLeftMouseUp
				set nextEventMonitor to GlobalMonitor's monitorNext_performSelector_target_(nextEventMask, "clearModButtons:", me)
			end if
		end if
	end lockButton_
	-------------------------------------------------------------------------
	
	---------- Set modkey buttons to reflect mask -----------
	------ in response to system modifier key change ------
	------ Does not change system modifier key state ------
	on setModButtonValues(mask)
		if buttonFlagMask = mask then return -- nothing to do
		if nextEventMonitor is not missing value then
			GlobalMonitor's removeMonitor_(nextEventMonitor)
			set nextEventMonitor to missing value -- if remove lock section,  restore monitor after
		end if
		
		set cmdState to (BitCalculations's andBitsOf_with_(current application's NSCommandKeyMask, mask))
		set my cmdButtonValue to (cmdState > 0) as integer
		
		set optState to (BitCalculations's andBitsOf_with_(current application's NSAlternateKeyMask, mask))
		set my optButtonValue to (optState > 0) as integer
		
		set ctlState to (BitCalculations's andBitsOf_with_(current application's NSControlKeyMask, mask))
		set my ctlButtonValue to (ctlState > 0) as integer
		
		set shftState to (BitCalculations's andBitsOf_with_(current application's NSShiftKeyMask, mask))
		set my shftButtonValue to (shftState > 0) as integer
		
		set buttonFlagMask to mask
		
		-- Since a system mod flag change probably happened in virtual keyboard, there is an impending NSLeftMouseUp. 
		-- So if we turn on the nextEvent monitor, we'll reset keys as we push them. 
		-- Since we are leaving it off, we'll indicate that by turning the lock on.
		if nextEventMonitor is missing value then
			if buttonFlagMask ≠ 0 then set my modKeyLockOn to 1
			if buttonFlagMask = 0 then set my modKeyLockOn to 0
		end if
	end setModButtonValues
	
	-------- Set system mod key state to reflect mask -------
	-------- Does not affect app's modifier buttons --------
	on setModFlagMaskTo_(mask)
		set newModMask to (NSEvent's modifierFlags) as integer
		if newModMask = mask then return -- nothing to do
		
		GlobalMonitor's removeMonitor_(flagChangeMonitor) --stop monitor to keep it from changing stuff while we click a mod key in Quickclicks
		
		tell application QCAppName -- record QC's bounds and visibility then move to lower corner and make visible
			set qcVisible to visible of window QCWindowName
			set qcBounds to bounds of window QCWindowName
			if qcVisible is false then
				set qcSizeX to (item 3 of qcBounds) - (item 1 of qcBounds)
				set qcSizeY to (item 4 of qcBounds) - (item 2 of qcBounds)
				set bounds of window QCWindowName to {0, 800, 0 + qcSizeX, 800 + qcSizeY}
				set visible of window QCWindowName to true
			end if
		end tell
		
		-- calculate modifier keys to change --
		if (BitCalculations's andBitsOf_with_(cmdBitMask, mask)) ≠ (BitCalculations's andBitsOf_with_(cmdBitMask, newModMask)) then
			toggleQCKey_("⌘")
		end if
		
		if (BitCalculations's andBitsOf_with_(optBitMask, mask)) ≠ (BitCalculations's andBitsOf_with_(optBitMask, newModMask)) then
			toggleQCKey_("⌥")
		end if
		
		if (BitCalculations's andBitsOf_with_(ctlBitMask, mask)) ≠ (BitCalculations's andBitsOf_with_(ctlBitMask, newModMask)) then
			toggleQCKey_("⌃")
			
		end if
		
		if (BitCalculations's andBitsOf_with_(shftBitMask, mask)) ≠ (BitCalculations's andBitsOf_with_(shftBitMask, newModMask)) then
			toggleQCKey_("⇧")
		end if
		
		--Reinstate Monitor--
		set flagChangeMonitor to GlobalMonitor's monitorEvery_performSelector_target_(current application's NSFlagsChangedMask, "modifierFlagsChanged:", me)
		
		---- Restore QC's bounds and visibility ----
		if qcVisible is false then
			tell application QCAppName
				set visible of window QCWindowName to qcVisible
				set bounds of window QCWindowName to qcBounds
			end tell
		end if
		return
	end setModFlagMaskTo_
	
	----------------------- Clear(x) Modifier Key ------------------------
	----------------------- Linked to UI button -------------------------
	on xClearModButtons_(sender)
		log "xClearModButtons"
		setModFlagMaskTo_(0)
		setModButtonValues(0)
	end xClearModButtons_
	-------------------------------------------------------------------------
	
	--------------- Clear Modifier Keys --------------
	-------- using setModButtonValues(0) --------
	---- in response to next NSLeftMouseUp -----
	on clearModButtons_(theEvent)
		log "clearModButtons"
		set nextEventMonitor to missing value -- to show nextEvent monitor is removed
		
		setModFlagMaskTo_(0)
		setModButtonValues(0)
		
		-- restore monitor if modkeys set and (lock off ???)
		-- in the event of a failure to clear modifier flags
		-- will usually reset on next click
		-- but might be smarter to wait 1 sec and try again
		set newModMask to (NSEvent's modifierFlags) as integer
		if newModMask ≠ 0 and modKeyLockOn as boolean is false then
			do shell script "sleep 1"
			set newModMask to (NSEvent's modifierFlags) as integer
			if newModMask ≠ 0 and modKeyLockOn as boolean is false then
				setModFlagMaskTo_(0)
				--set nextEventMonitor to GlobalMonitor's monitorNext_performSelector_target_(nextEventMask, "clearModButtons:", me)
			end if
		end if
	end clearModButtons_
	
	-------- A change in system modifier flags --------
	---- resets modifier button to reflect change ----
	--- using setModButtonValues(newModMask) ---
	on modifierFlagsChanged_(theEvent)
		set newModMask to (NSEvent's modifierFlags) as integer
		if newModMask is buttonFlagMask then -- nothing to do
			set flagMonitorOn to true
			log "other hi"
			return
		end if
		log "hi"
		setModButtonValues(newModMask)
	end modifierFlagsChanged_
	
	----------------------- Begin Keystroke Keys ------------------------
	----------------------- Linked to UI buttons -------------------------	
	on escapeKey_(sender)
		tell application "System Events" to key code 53
	end escapeKey_
	
	on deleteKey_(sender)
		tell application "System Events" to key code 51
		
	end deleteKey_
	
	on spaceKey_(sender)
		tell application "System Events" to key code 49
	end spaceKey_
	
	on tabKey_(sender)
		tell application "System Events" to key code 48
	end tabKey_
	
	on returnKey_(sender)
		tell application "System Events" to key code 36
	end returnKey_
	
	on upArrowKey_(sender)
		tell application "System Events" to key code 126
	end upArrowKey_
	
	on downArrowKey_(sender)
		tell application "System Events" to key code 125
	end downArrowKey_
	
	on rightArrowKey_(sender)
		tell application "System Events" to key code 124
	end rightArrowKey_
	
	on leftArrowKey_(sender)
		tell application "System Events" to key code 123
	end leftArrowKey_
	
	----------------------- AppleScripted Buttons ------------------------
	----------------------- Linked to UI buttons --------------------------
	on keyboardButton_(sender)
		tell application QCAppName
			if visible of window QCWindowName is true then
				set visible of window QCWindowName to false
			else
				set visible of window QCWindowName to true
			end if
		end tell
	end keyboardButton_
	
	on preferencesButton_(sender)
		tell application "System Preferences"
			reveal pane "Pen Tablet"
			activate
		end tell
	end preferencesButton_
	
	on resetTabletButton_(sender)
		try
			do shell script "killall " & quoted form of PenTabletDriverName
		on error
			try
				do shell script "killall -9 " & quoted form of PenTabletDriverName
			end try
		end try
		delay 0.2
		tell application PenTabletDriverName to launch
	end resetTabletButton_
	-------------------------------------------------------------------------
	
	-------------------------------------------------------------------------
	on awakeFromNib()
		testQuickclicksAndAssitiveEnabled() -- Test for Quickclicks presence and for assistive devices enabled.
		
		keyPanel's setLevel_(64) -- above Quicksilver, below Axiotron Quickscript
		keyPanel's setCollectionBehavior_(1) -- Panel present on all Desktop Spaces
		
		-- Monitor every change in system modifier state --
		set flagChangeMonitor to GlobalMonitor's monitorEvery_performSelector_target_(current application's NSFlagsChangedMask, "modifierFlagsChanged:", me)
		
		-- set mod key buttons to reflect present system modifier state --
		set newModMask to (NSEvent's modifierFlags) as integer
		setModButtonValues(newModMask)
		
		-- If lock off and modkeys set, monitor next click to reset modkeys
		if modKeyLockOn is 0 and buttonFlagMask ≠ 0 then
			set nextEventMonitor to GlobalMonitor's monitorNext_performSelector_target_(nextEventMask, "clearModButtons:", me)
		end if
	end awakeFromNib
	
	on applicationWillFinishLaunching_(aNotification)
		-- Insert code here to initialize your application before any files are opened 
		log keyPanel's windowNumber
	end applicationWillFinishLaunching_
	
	---- If window moved, send window to nearest screen edge ----
	on windowDidMove_(aNotification)
		if windowIsMoving is true then return -- if window moving to edge, let it move undisturbed
		set windowIsMoving to true
		set theFrame to (keyPanel's frame) as record
		
		do shell script "sleep .05" -- pause before moving window to edge
		
		-- calculate edge location --
		if (x of origin of theFrame) < 640 then
			set (x of origin of theFrame) to 10
		else
			set (x of origin of theFrame) to 1240
		end if
		
		keyPanel's setFrame_display_animate_(theFrame, true, true)
		performSelector_withObject_afterDelay_("endWindowMove", missing value, 1)
	end windowDidMove_
	
	on endWindowMove() -- after 1 sec, reset windowIsMoving flag
		set windowIsMoving to false
	end endWindowMove
	
	-- Set app to TerminateAfterLastWindowClosed
	on applicationShouldTerminateAfterLastWindowClosed_(sender)
		return true
	end applicationShouldTerminateAfterLastWindowClosed_
	
	on applicationShouldTerminate_(sender)
		-- Insert code here to do any housekeeping before your application quits 
		return current application's NSTerminateNow
	end applicationShouldTerminate_
	
end script