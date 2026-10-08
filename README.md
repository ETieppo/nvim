# My little nightmares

## If you are asking whathell is this

Its just another nvim... hmm, I dont know whether an setting or distro..., anyway
you know what means linuxporn? if you do so, its going at same way

## Why little nightmares??

Soo... what you'r talking about?
I have try so many editors and none did things exacly like need,
for a while I thogth that's has been about how my knowledge about
configuring has worked, but as the over time it was taking clear,
I admit that was not wrong, cause now lsp, formatters and is not
vage anymore, even not same thing.

any of then take slowing at some file types, have no much plugins,
or even just broken some setting between versions, it was making me
so mad, the lastone was Zed, incredible as it may seem it was the
best one, I realy loved how it do search, maintain settings, even
make easier to create new thigs, change keymaps, I stay on it for
a while, but I started to use too early(there for 0.110)
unfortnetlly I missed about plugins, especially for languages lsp

Every new lang that has no plugin for, i struggle to configure, as
a new editor it's understandable to not have impeccable doc, by it
change every time, I lost myself so many times... `(0_0)`

I really try, but one day I get tierd, started to search again, and
this time I decided it wold be the last time, I forbade to change
to another one if some editor fit what needed, by this I wrote what
a perfect editor need to do, I remember to think about open big
minified files even lsp both to not getting stucked.

Calm down, it gets worse. So, I found like 3-4 editors, among were
helix(good options, but simple at some parts like customizations),
kakoune(I found bad docs), and then I stay between Emacs(Thanks to
my past self that I don't decided for it), confess because it seemed
old, but it only seemed so, I evaluated it again after a while and
today I understand that it is a powerful editor, and the current
reason is that it uses lisp and the lsp is not quite lsp.

then I started to understand about vim and nvim, "every item at my
list of a perfect editor was match", and the quotes cause its like
a test suite, you only know the software have no the tested bug, but
not have no bugs, I'll get there.

I was faccinated about neovim, the idea and how it works, with two
additional, first lua is the config lang, I already knew, then, I'm
passionated about terminals, I used to use it for every OS handle,
then I decide to stay and learn, you remember that I forbade myself?
Started there, needed to make it my IDE, how?? no idea..., I has been
try so many distros, struggled at every, Each one had a characteristic
that didn't fit on my list, I don't even need to mention how painfull
is to learn it `(X_X)`, especially if you has been used gui based editors,
I never knew when it was Neovim and when it was Distro, I had no other
choice, so I kept searching until I found Kickstart I started to feel
free to ride as I needed/wanted.

the settings change so many times, I don't think it's even like kickstart
any more, but in the over time it got overwhelmed, many plugins, too
long to install, so havy for servers, I got problems with performance,
didn't really know lua, I got lost in the organisation and so on...
even pc damn energy `(#_#)` kkkkk que ódio

in short, today the editor has ~70 lua files and it tends to grow. the
point is that i learned what lsp really is in the process, stopped using
a lot of plugins and started using nvim to configure anything new. i try
not to install much stuff that won't change much, which ended up making
me remove the minimap and other plugins i now consider unnecessary. and
believe it or not, a lot of people complain about two things i don't
feel with my current config: the time nvim takes to open (it's the same
as vanilla, no idea how) and that some updates break parts of the editor,
forcing you to refactor entire files (also no idea how)

the organization i only managed to fix now, after 4 months. the worst case
was languages, to add a new one i had to touch core, formatters and lsp,
ridiculously fragmented. today i have 1 file per language, and that file is
responsible for registering everything. if it's gone, the language simply stops
existing

and the gui, holy shit, talk about something that was a pain. the day i found
out it could look the way i imagined was when my world fell apart. today it's
exactly how i work, think, or even edit. it's almost flawless, i just need to
finish organizing it, and there might be some little bug hiding somewhere since
there are no tests

and about little nightmares, Im pretty picky and was 4 months for all that
I described... it was painfull but now I'm pretty happy that it was mine
decision even so it look's and work like I idealised.
