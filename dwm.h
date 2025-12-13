#ifndef DWM_H
#define DWM_H
// clang-format off

#include <X11/X.h>
#include <X11/Xatom.h>
#include <X11/Xft/Xft.h>
#include <X11/Xlib.h>
#include <X11/Xproto.h>
#include <X11/Xutil.h>
#include <X11/cursorfont.h>
#include <X11/keysym.h>
#include <limits.h>
#include <stdarg.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#include "src/drw.h"
#include "src/util.h"

#define MAXTAGS 8
#define MINTAGS 5

#define BUTTONMASK               (ButtonPressMask | ButtonReleaseMask)
#define CLEANMASK(mask)          (mask & ~(numlockmask | LockMask) & (ShiftMask | ControlMask | Mod1Mask | Mod2Mask | Mod3Mask | Mod4Mask | Mod5Mask))
#define INTERSECT(x, y, w, h, m) (MAX(0, MIN((x) + (w), (m)->wx + (m)->ww) - MAX((x), (m)->wx)) * MAX(0, MIN((y) + (h), (m)->wy + (m)->wh) - MAX((y), (m)->wy)))
#define ISVISIBLE(C)             ((C->isglobal || C->tags & C->mon->tagset[C->mon->seltags]))
#define LENGTH(X)                (sizeof X / sizeof X[0])
#define MOUSEMASK                (BUTTONMASK | PointerMotionMask)
#define WIDTH(X)                 ((X)->w + 2 * (X)->bw)
#define HEIGHT(X)                ((X)->h + 2 * (X)->bw)
#define TAGMASK                  ((1 << MAXTAGS) - 1)
#define TEXTW(X)                 (drw_fontset_getwidth(drw, (X)) + lrpad)
#define TAG(x)                   ((1 << (x)))
#define TAGHIDE                  ((TAG(5) | TAG(6) | TAG(7)))

enum { CurNormal, CurResize, CurMove, CurLast };
enum { SchemeNorm, SchemeSel };
enum { NetSupported, NetWMName, NetWMIcon, NetWMState, NetWMCheck, NetWMFullscreen, NetActiveWindow, NetWMWindowType, NetWMWindowTypeDialog, NetClientList, NetLast };
enum { WMProtocols, WMDelete, WMState, WMTakeFocus, WMLast };
enum { ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, ClkRootWin, ClkLast };

typedef struct Arg Arg;
typedef struct Button Button;
typedef struct Client Client;
typedef struct Key Key;
typedef struct Layout Layout;
typedef struct Monitor Monitor;
typedef struct Rule Rule;
typedef struct Pertag Pertag;

struct Arg {
	int i;
	unsigned int ui;
	float f;
	const void *v;
};

struct Button {
	unsigned int click;
	unsigned int mask;
	unsigned int button;
	void (*func)(const Arg *arg);
	const Arg arg;
};

struct Client {
	char name[256];
	float mina, maxa;
	int x, y, w, h;
	int oldx, oldy, oldw, oldh;
	int basew, baseh, incw, inch, maxw, maxh, minw, minh, hintsvalid;
	int bw, oldbw;
	unsigned int tags;
	int isfixed, isfloating, isglobal, isurgent, neverfocus, oldstate, isfullscreen;
	unsigned int icw, ich;
	Picture icon;
	Client *next;
	Client *snext;
	Monitor *mon;
	Window win;
};

struct Key {
	unsigned int mod;
	KeySym keysym;
	void (*func)(const Arg *);
	const Arg arg;
};

struct Layout {
	const char *symbol;
	void (*arrange)(Monitor *);
};

struct Monitor {
	char ltsymbol[16];
	float mfact;
	int nmaster;
	int num;
	int by;             /* bar geometry */
	int mx, my, mw, mh; /* screen size */
	int wx, wy, ww, wh; /* window area  */
	int pvx, pvs;       /* tags & title size */
	unsigned int seltags;
	unsigned int sellt;
	unsigned int tagset[2];
	int showbar;
	int topbar;
	Client *clients;
	Client *sel;
	Client *stack;
	Monitor *next;
	Window barwins[3];
	const Layout *lt[2];
	Pertag *pertag;
};

struct Rule {
	const char *class;
	const char *instance;
	const char *title;
	unsigned int tags;
	int isfloating;
	int isglobal;
	int monitor;
	int unmanaged;
};

struct Pertag {
	unsigned int curtag;
	int nmasters[MAXTAGS];
	unsigned int sellts[MAXTAGS];
	const Layout *ltidxs[MAXTAGS][2];
};

void applyrules(Client *c);
int applysizehints(Client *c, int *x, int *y, int *w, int *h, int interact);
void arrange(Monitor *m);
void arrangemon(Monitor *m);
void attach(Client *c);
void attachstack(Client *c);
void autostart(void);
void buttonpress(XEvent *e);
void checkotherwm(void);
void cleanup(void);
void cleanupmon(Monitor *mon);
void clientmessage(XEvent *e);
void clkstatusbar(const Arg *arg);
void configure(Client *c);
void configurenotify(XEvent *e);
void configurerequest(XEvent *e);
Monitor *createmon(void);
void destroynotify(XEvent *e);
void detach(Client *c);
void detachstack(Client *c);
Monitor *dirtomon(int dir);
void drawbar(Monitor *m);
void drawbars(void);
void enternotify(XEvent *e);
void expose(XEvent *e);
void focus(Client *c);
void focusin(XEvent *e);
void focusmon(const Arg *arg);
void focusstack(const Arg *arg);
Atom getatomprop(Client *c, Atom prop);
Picture geticonprop(Window win, unsigned int *picw, unsigned *pich);
int getrootptr(int *x, int *y);
long getstate(Window w);
int gettextprop(Window w, Atom atom, char *text, unsigned int size);
void grabbuttons(Client *c, int focused);
void grabkeys(void);
void incnmaster(const Arg *arg);
void keypress(XEvent *e);
void killclient(const Arg *arg);
void manage(Window w, XWindowAttributes *wa);
void mappingnotify(XEvent *e);
void maprequest(XEvent *e);
void monocle(Monitor *m);
void motionnotify(XEvent *e);
void movemouse(const Arg *arg);
Client *nexttiled(Client *c);
void pertagupdate(Monitor *m);
void pop(Client *c);
void propertynotify(XEvent *e);
void quit(const Arg *arg);
Monitor *recttomon(int x, int y, int w, int h);
void resize(Client *c, int x, int y, int w, int h, int interact);
void resizeclient(Client *c, int x, int y, int w, int h);
void resizemouse(const Arg *arg);
void restack(Monitor *m);
void run(void);
void scan(void);
int sendevent(Client *c, Atom proto);
void sendmon(Client *c, Monitor *m);
void setclientstate(Client *c, long state);
void setfocus(Client *c);
void setfullscreen(Client *c, int fullscreen);
void setlayout(const Arg *arg);
void setmfact(const Arg *arg);
void setup(void);
void seturgent(Client *c, int urg);
void showhide(Client *c);
void spawn(const Arg *arg);
void tag(const Arg *arg);
void tagmon(const Arg *arg);
void tile(Monitor *m);
void togglebar(const Arg *arg);
void togglefloating(const Arg *arg);
void toggleglobal(const Arg *arg);
void toggleview(const Arg *arg);
void freeicon(Client *c);
void transfer(const Arg *arg);
void unfocus(Client *c, int setfocus);
void unmanage(Client *c, int destroyed);
void unmapnotify(XEvent *e);
void updatebarpos(Monitor *m);
void updatebars(void);
void updateclientlist(void);
int updategeom(void);
void updatenumlockmask(void);
void updatesizehints(Client *c);
void updatestatus(void);
void updatetitle(Client *c);
void updateicon(Client *c);
void updatewindowtype(Client *c);
void updatewmhints(Client *c);
void view(const Arg *arg);
void viewontag(const Arg *arg);
Client *wintoclient(Window w);
Monitor *wintomon(Window w);
int xerror(Display *dpy, XErrorEvent *ee);
int xerrordummy(Display *dpy, XErrorEvent *ee);
int xerrorstart(Display *dpy, XErrorEvent *ee);
void zoom(const Arg *arg);

const char broken[] = "broken";
char stext[256];
char *btnstr[6] = {
	[Button1] = "L",  /* left mouse button */
	[Button2] = "M",  /* middle mouse button */
	[Button3] = "R",  /* right mouse button */
	[Button4] = "U",  /* mouse wheel up */
	[Button5] = "D"}; /* mouse wheel down */
int screen;
int sw, sh;    /* X display screen geometry width, height */
int bh;        /* bar height */
int unmanaged; /* whether the WM should manage the new window */
int lrpad;     /* sum of left and right padding for text */
int (*xerrorxlib)(Display *, XErrorEvent *);
unsigned int numlockmask = 0;
void (*handler[LASTEvent])(XEvent *) = {
	[ButtonPress]      = buttonpress,
	[ClientMessage]    = clientmessage,
	[ConfigureRequest] = configurerequest,
	[ConfigureNotify]  = configurenotify,
	[DestroyNotify]    = destroynotify,
	[EnterNotify]      = enternotify,
	[Expose]           = expose,
	[FocusIn]          = focusin,
	[KeyPress]         = keypress,
	[MappingNotify]    = mappingnotify,
	[MapRequest]       = maprequest,
	[MotionNotify]     = motionnotify,
	[PropertyNotify]   = propertynotify,
	[UnmapNotify]      = unmapnotify};
Atom wmatom[WMLast], netatom[NetLast];
int running = 1;
Cur *cursor[CurLast];
Clr **scheme;
Display *dpy;
Drw *drw;
Monitor *mons, *selmon;
Window root, wmcheckwin;

// clang-format on
#endif  // !DWM_H
