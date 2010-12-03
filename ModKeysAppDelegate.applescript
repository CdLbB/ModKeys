--
--  ModKeysAppDelegate.applescript
--  ModKeys
--
--  Created by Eric Nitardy on 11/30/10.
--  Copyright 2010 University of Washington. All rights reserved.
--

property ModifierKeyChange : class "ModifierKeyChange"
property BitCalculations : class "BitCalculations"
property GlobalMonitor : class "GlobalMonitor"

property NSEvent : class "NSEvent"



script ModKeysAppDelegate
	property parent : class "NSObject"
	
	property flagChangeMonitor : missing value
	property storedSysModMask : missing value
	
	property cmdButtonValue : missing value
	property optButtonValue : missing value
	property ctlButtonValue : missing value
	property shftButtonValue : missing value
	
	property keyPanel : missing value
	
	on modifiyPenTip(senderState, bitMaskChange)
		if senderState is current application's NSOffState then
			tell application "TabletDriver"
				set penModMask to button modifiers of button 1 of transducer 1 of tablet 1
				set newModMask to (BitCalculations's deleteBitsOf_from_(bitMaskChange, penModMask)) as integer
				if newModMask is 0 then
					set button function of button 1 of transducer 1 of tablet 1 to click
					set button modifiers of button 1 of transducer 1 of tablet 1 to 0
				else
					set button modifiers of button 1 of transducer 1 of tablet 1 to newModMask + 32
				end if
			end tell
			
		else if senderState is current application's NSOnState then
			tell application "TabletDriver"
				set penModMask to button modifiers of button 1 of transducer 1 of tablet 1
				set newModMask to (BitCalculations's orBitsOf_with_(bitMaskChange, penModMask)) as integer
				
				set button function of button 1 of transducer 1 of tablet 1 to press modifiers
				set button modifiers of button 1 of transducer 1 of tablet 1 to newModMask
			end tell
			
		end if
	end modifiyPenTip
	
	on modifierFlagsChanged_(theEvent)
		if storedSysModMask is missing value then return
		
		--set oldModMask to theEvent's modifierFlags
		set newModMask to (NSEvent's modifierFlags) as integer
		--set theType to theEvent's type
		if newModMask ≠ storedSysModMask then
			do shell script "sleep 0.3"
			set newModMask to (NSEvent's modifierFlags) as integer
			if newModMask ≠ storedSysModMask then
				log newModMask
				log storedSysModMask
				--set changeBit to (BitCalculations's xorBitsOf_with_(storedSysModMask, newModMask))
				--set changeMask to (BitCalculations's andBitsOf_with_(newModMask, changeBit))
				--set buttonMask to (BitCalculations's orBitsOf_with_(newModMask, changeMask)) 
				adjustModButtonValues(newModMask)
				set storedSysModMask to newModMask
			end if
		end if
	end modifierFlagsChanged_
	
	on adjustModButtonValues(mask)
		set cmdState to (BitCalculations's andBitsOf_with_(current application's NSCommandKeyMask, mask))
		set my cmdButtonValue to (cmdState > 0) as integer
		
		set optState to (BitCalculations's andBitsOf_with_(current application's NSAlternateKeyMask, mask))
		set my optButtonValue to (optState > 0) as integer
		
		set ctlState to (BitCalculations's andBitsOf_with_(current application's NSControlKeyMask, mask))
		set my ctlButtonValue to (ctlState > 0) as integer
		
		set shftState to (BitCalculations's andBitsOf_with_(current application's NSShiftKeyMask, mask))
		set my shftButtonValue to (shftState > 0) as integer
	end adjustModButtonValues
	
	on commandKey_(sender)
		set bitMaskChange to 32 + 16
		modifiyPenTip((sender's state) as integer, bitMaskChange)
	end commandKey_
	
	on optionKey_(sender)
		set bitMaskChange to 32 + 8
		modifiyPenTip((sender's state) as integer, bitMaskChange)
	end optionKey_
	
	on controlKey_(sender)
		set bitMaskChange to 32 + 2
		modifiyPenTip((sender's state) as integer, bitMaskChange)
	end controlKey_
	
	on shiftKey_(sender)
		set bitMaskChange to 32 + 4
		modifiyPenTip((sender's state) as integer, bitMaskChange)
	end shiftKey_
	
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
	
	on awakeFromNib()
		keyPanel's setLevel_(64) -- above Quicksilver, below Axiotron Quickscript
		keyPanel's setCollectionBehavior_(1) -- Panel present on all Desktop Spaces
		
		set flagChangeMonitor to GlobalMonitor's monitorEvery_ignoring_performSelector_target_(current application's NSFlagsChangedMask, current application's NSLeftMouseDownMask, "modifierFlagsChanged:", me)
		
		set storedSysModMask to (NSEvent's modifierFlags) as integer
		adjustModButtonValues(storedSysModMask)
	end awakeFromNib
	
	on applicationWillFinishLaunching_(aNotification)
		-- Insert code here to initialize your application before any files are opened 
	end applicationWillFinishLaunching_
	
	on applicationShouldTerminate_(sender)
		-- Insert code here to do any housekeeping before your application quits 
		tell application "TabletDriver"
			set button function of button 1 of transducer 1 of tablet 1 to click
			set button modifiers of button 1 of transducer 1 of tablet 1 to 0
		end tell
		return current application's NSTerminateNow
	end applicationShouldTerminate_
	
end script