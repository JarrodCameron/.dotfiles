import System.Exit
import XMonad
import XMonad.Actions.WorkspaceNames
import XMonad.Config.Desktop
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Util.Run

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

myTerminal      = "termite"
myBorderWidth   = 1
myModMask       = mod4Mask
myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]
myNormalBorderColor  = "#dddddd"
myFocusedBorderColor = "#ff0000"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm,               xK_Return), spawn $ XMonad.terminal conf)

    -- Swap the focused window and the master window
    , ((modm .|. shiftMask, xK_Return), spawn "~/.scripts/.wm/samedir.sh")

--    -- Swap the focused window and the master window
--    , ((modm .|. shiftMask, xK_Return), windows W.swapMaster)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Run bookmark script
    , ((modm,               xK_b     ), spawn "~/.scripts/.wm/bookmarks.sh")

    -- toggle the status bar gap
    , ((modm .|. shiftMask, xK_b     ), sendMessage ToggleStruts)

    -- Open the browser
    , ((modm,               xK_c     ), spawn "firefox")

    -- Open the browser (private)
    , ((modm .|. shiftMask, xK_c     ), spawn "firefox --private-window")

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Script to rearrange screens
    , ((modm .|. shiftMask, xK_m     ), spawn "~/.scripts/.wm/screen")

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- launch dmenu
    , ((modm,               xK_p     ), spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\"")

    -- close focused window
    , ((modm .|. shiftMask, xK_q     ), kill)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modMask, button1), (\w -> focus w >> mouseMoveWindow w))

    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2), (\w -> focus w >> windows W.swapMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3), (\w -> focus w >> mouseResizeWindow w))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = tiled ||| Full
    where
        -- default tiling algorithm partitions the screen into two panes
        tiled   = Tall nmaster delta ratio

        -- The default number of windows in the master pane
        nmaster = 1

        -- Default proportion of screen occupied by master pane
        ratio   = 1/2

        -- Percent of screen to increment by when resizing panes
        delta   = 3/100

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

------------------------------------------------------------------------
-- Status bars and logging

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do
    spawn "~/.scripts/.wm/init_screen.sh"
    spawn "~/.scripts/.wm/wallpaper.sh"

windowCount     = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
--main = xmonad $ ewmh $ defaults
main = do

    xmonad $ ewmh desktopConfig
        { manageHook = ( isFullscreen --> doFullFloat ) <+> myManageHook <+> manageHook desktopConfig <+> manageDocks
        , logHook = dynamicLogWithPP $ xmobarPP
             { ppCurrent = xmobarColor "#c3e88d" "" . wrap "[" "]" -- Current workspace in xmobar
             , ppVisible = xmobarColor "#c3e88d" ""                -- Visible but not current workspace
             , ppHidden = xmobarColor "#82AAFF" "" . wrap "*" ""   -- Hidden workspaces in xmobar
             , ppHiddenNoWindows = xmobarColor "#F07178" ""        -- Hidden workspaces (no windows)
             , ppTitle = xmobarColor "#d0d0d0" "" . shorten 80     -- Title of active window in xmobar
             , ppSep =  "<fc=#9AEDFE> : </fc>"                     -- Separators in xmobar
             , ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!"  -- Urgent workspace
             , ppExtras  = [windowCount]                           -- # of windows current workspace
             , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
             }

        , terminal           = myTerminal
        , focusFollowsMouse  = myFocusFollowsMouse
        , borderWidth        = myBorderWidth
        , modMask            = myModMask
        , workspaces         = myWorkspaces
        , normalBorderColor  = myNormalBorderColor
        , focusedBorderColor = myFocusedBorderColor

        -- key bindings
        , keys               = myKeys
        , mouseBindings      = myMouseBindings

        -- hooks, layouts
        , layoutHook         = myLayout
        --, manageHook         = myManageHook
        , startupHook        = myStartupHook
        }
