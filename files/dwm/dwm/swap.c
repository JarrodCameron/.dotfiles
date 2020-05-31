static void swap(const Arg *arg);
static void xchg(void *a, void *b, unsigned int len);
static void setclients(Monitor *dest, Client *c);
static void getclients(Monitor *src, Client **ret);

void
swap(const Arg *arg)
{
	(void) arg;

	Client *c1, *c2;

	if (!mons->next)
		return; /* No dual monitor */

	if (selmon->sel)
		unfocus(selmon->sel, 1);

	getclients(mons, &c1);
	getclients(mons->next, &c2);

	setclients(mons->next, c1);
	setclients(mons, c2);

	xchg(&mons->mfact,    &mons->next->mfact,    sizeof(mons->mfact));
	xchg(&mons->nmaster,  &mons->next->nmaster,  sizeof(mons->nmaster));
	xchg(&mons->showbar,  &mons->next->showbar,  sizeof(mons->showbar));
	xchg(&mons->topbar,   &mons->next->topbar,   sizeof(mons->topbar));
	xchg(&mons->sellt,    &mons->next->sellt,    sizeof(mons->sellt));
	xchg(&mons->lt,       &mons->next->lt,       sizeof(mons->lt));
	xchg(&mons->ltsymbol, &mons->next->ltsymbol, sizeof(mons->ltsymbol));

	focus(NULL);
	arrange(NULL);
/* TODO How do we redraw the bar??? */
}

void
xchg(void *a, void *b, unsigned int len)
{
	char *arr1, *arr2;
	unsigned int i;

	arr1 = a;
	arr2 = b;

	for (i = 0; i < len ;i++) {
		arr1[i] = arr1[i] ^ arr2[i];
		arr2[i] = arr1[i] ^ arr2[i];
		arr1[i] = arr1[i] ^ arr2[i];
	}
}

/* Given a list of clients "c" insert them into the Monitor "dest" */
void
setclients(Monitor *dest, Client *c)
{
	if (!c)
		return;

	Client *next = c->next;

	c->mon = dest;
	c->tags = dest->tagset[dest->seltags];
	attach(c);
	attachstack(c);

	setclients(dest, next);
}

/* Store all the clients on Monitor "src" into "ret" */
void
getclients(Monitor *src, Client **ret)
{
	Client *curr, *next;

	*ret = NULL;

	curr = src->clients;
	next = NULL;

	while (curr != NULL) {
		next = curr->next;

		if (curr->tags == src->tagset[src->seltags]) {
			detach(curr);
			detachstack(curr);

			curr->next = *ret;
			*ret = curr;
		}

		curr = next;
	}

}
