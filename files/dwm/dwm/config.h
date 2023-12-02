/* See LICENSE file for copyright and license details. */

#include <X11/XF86keysym.h> /* For the XF86XK_* keys */

/* Patches */
#include "swap.c"

/* appearance */
static const unsigned int borderpx  = 1;        /* border pixel of windows */
static const unsigned int snap      = 16;       /* snap pixel */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const char *fonts[]          = { "monospace:size=10" };
static const char dmenufont[]       = "monospace:size=10";
static const char col_gray1[]       = "#282828";
static const char col_gray2[]       = "#ffe4b5";
static const char col_gray3[]       = "#ffe4b5";
static const char col_gray4[]       = "#fabd2f"; /* Old: #ffe4b5 */
static const char col_cyan[]        = "#282828";

static const char *colors[][3]      = {
	/*               fg         bg         border   */
	[SchemeNorm] = { col_gray3, col_gray1, col_gray2 },
	[SchemeSel]  = { col_gray4, col_cyan,  col_cyan  },
};

/* Strings given to system() */
static const char *inits[] = {
	"~/.scripts/.wm/init_screen.sh",
	"~/.scripts/.wm/wallpaper.sh",
	"~/.scripts/.dwm/menubar.sh &",
	"dunst &",
};

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class      instance    title       tags mask  iscentered    isfloating   monitor */
	{ "Gimp",     NULL,       NULL,       0,         0,             1,           -1 },
	{ NULL,       "termite",  "p3calc",   0,         1,             1,           -1 },
	{ "feh-qr",   "feh",      NULL,       0,         1,             1,           -1 },
	{ "feh-graph","feh",      NULL,       0,         1,             1,           -1 },
};

/* layout(s) */
static const float mfact     = 0.50; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },    /* first entry is default */
	{ "[M]",      monocle }, /* full screen */
	{ "><>",      NULL },    /* no layout function means floating behavior */
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = {"dmenu_run", "-m", dmenumon, "-fn", dmenufont, "-nb", col_gray1, "-nf", col_gray3, "-sb", col_cyan, "-sf", col_gray4, NULL};
static const char *termcmd[] = {"termite", NULL};
static const char *firefox[] = {"firefox", NULL};
static const char *alacritty[] = {"alacritty", NULL};
static const char *pfirefox[] = {"firefox", "--private-window", NULL};
static const char *bookmarks[] = {HOME "/.config/dwm/scripts/google-chrome-bookmarks.sh", NULL};
static const char *screensh[] = {HOME "/.scripts/.wm/screen.sh", NULL};
static const char *editconfig[] = {HOME "/.scripts/.wm/editconfig.sh", NULL};
static const char *volup[] = {"pactl", "set-sink-volume", "@DEFAULT_SINK@", "-2%", NULL};
static const char *voldown[] = {"pactl", "set-sink-volume", "@DEFAULT_SINK@", "+2%", NULL};
static const char *voltoggle[] = {"pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle", NULL};
static const char *automan[] = {HOME "/.scripts/.wm/automan.sh", NULL};
static const char *brightup[] =   {"xbacklight", "-inc", "10", NULL};
static const char *brightdown[] = {"xbacklight", "-dec", "10", NULL};
static const char *wallpaper[] = {HOME "/.scripts/.wm/wallpaper.sh", NULL};
static const char *p3calc[] = {HOME "/.scripts/.wm/p3calc.sh", NULL};
static const char *lockscreen[] = {HOME "/.scripts/.wm/lock-screen.sh", NULL};

static Key keys[] = {
	/* modifier                     key        function        argument */
	{ MODKEY,                       XK_Tab,    view,           {0} },
	{ MODKEY,                       XK_Return, spawn,          {.v = alacritty } },
	{ MODKEY|ShiftMask,             XK_Return, zoom,           {0} },
	{ MODKEY,                       XK_space,  setlayout,      {0} },
	{ MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
	{ MODKEY,                       XK_0,      view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
	{ MODKEY,                       XK_a,      spawn,          {.v = automan } },
	{ MODKEY,                       XK_b,      spawn,          {.v = bookmarks} },
	{ MODKEY|ShiftMask,             XK_b,      togglebar,      {0} },
	{ MODKEY,                       XK_c,      spawn,          {.v = firefox} },
	{ MODKEY|ShiftMask,             XK_c,      spawn,          {.v = pfirefox} },
	{ MODKEY,                       XK_d,      incnmaster,     {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_d,      incnmaster,     {.i = +1 } },
	{ MODKEY,                       XK_e,      spawn,          {.v = editconfig } },
	{ MODKEY,                       XK_f,      setlayout,      {.v = &layouts[2]} },
	{ MODKEY,                       XK_h,      focusmon,       {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_h,      tagmon,         {.i = -1 } },
	{ MODKEY,                       XK_i,      setmfact,       {.f = +0.05} },
	{ MODKEY|ShiftMask,             XK_i,      spawn,          {.v = lockscreen} },
	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
	{ MODKEY,                       XK_l,      focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_l,      tagmon,         {.i = +1 } },
	{ MODKEY,                       XK_m,      setlayout,      {.v = &layouts[1]} },
	{ MODKEY|ShiftMask,             XK_m,      spawn,          {.v = screensh} },
	{ MODKEY|ShiftMask,             XK_n,      spawn,          {.v = wallpaper} },
	{ MODKEY,                       XK_p,      spawn,          {.v = dmenucmd } },
	{ MODKEY|ShiftMask,             XK_p,      spawn,          {.v = p3calc } },
	{ MODKEY|ShiftMask,             XK_q,      killclient,     {0} },
	{ MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
	{ MODKEY,                       XK_u,      setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_z,      swap,           {0} },
	{ 0,              XF86XK_AudioLowerVolume, spawn,          {.v = volup} },
	{ 0,              XF86XK_AudioRaiseVolume, spawn,          {.v = voldown} },
	{ 0,              XF86XK_AudioMute,        spawn,          {.v = voltoggle} },
	{ 0,               XF86XK_MonBrightnessUp, spawn,          {.v = brightup} },
	{ 0,             XF86XK_MonBrightnessDown, spawn,          {.v = brightdown} },
	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	TAGKEYS(                        XK_6,                      5)
	TAGKEYS(                        XK_7,                      6)
	TAGKEYS(                        XK_8,                      7)
	TAGKEYS(                        XK_9,                      8)
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};
