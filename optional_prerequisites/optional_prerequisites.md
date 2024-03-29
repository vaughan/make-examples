# optional prerequisites in makefiles

Is it possible to have a list of prerequisite files, for example a list of possibilities generated by wildcard characters, that are optional for the target, but that if present will enforce remake of target if changed?

### non-optional:
```makefile
one: one.txt
	sed 's/a/*/g' $< > $@
```

We see that if the prerequisite is not present, make will be blocked there and render nothing.

```console
$ make -f optional_prerequisites.makefile one
make: *** No rule to make target 'one.txt', needed by 'one'.  Stop.
```

Unless we furnish the prerequisite.

```console
$ cat > one.txt
this is a one: 1
$ make -f optional_prerequisites.makefile one
sed 's/a/*/g' one.txt > one
$ cat one
this is * one: 1
```

### optional (a try) :

Using wildcard characters in the filename of the prerequisite should make that prerequisite optional, shouldn't it? (How could make halt and require the existence of a specific file in the case wildcard characters which would offer a near-infinite number of possible specific filenames?) However it would still presumeably enforce a remake of the target any time one of those specific files changes.

```makefile
two: two*.txt
	echo "$(date) $?" >> $@
```

Now lets try this with no matching files present.

```console
$ make -f optional_prerequisites.makefile two
make: *** No rule to make target 'two*.txt', needed by 'two'.  Stop.
```

Wrong.  Make does require the existence of at least one specific file matching the wildcard.

```console
$ cat > two222.txt
this is two-hundred twenty-two: 222  
$ make -f optional_prerequisites.makefile two
echo " two222.txt" >> two
```

Adding at least one specific matching file allows make to continue it's run.

This confirms what is mentioned in sectin `4.3 Types of Prerequisites` in the `make manual`, which mentions two types of prequisites: `normal` prerequisites and `order only` prerequisites.  `Order only` prequisites only require the prior existence if the prerequisite before the target and will compile the target only once, never to be updated.

Section `4.1 Rule Syntax` specifies that wildcard *characters* may be used, elucidated in section `4.3 Using Wildcard Characters in File names` which contains examples of rules that fire in the event of changes to multiple files (any of the matching files).

But there is no mention of a notion of `optional prerequisites`.  This is where the `wildcard` function comes in handy, introduced in the `makefile manual` in section `4.3 The Function *wildcard*`:

>  *$(wildcard pattern...)* \
> This string, used anywhere in a makefile, is replaced by a space-separated list of names of existing files that match one of the given file name patterns.

### The *real* optional:

Lets use the `wildcard` function:

```makefile
three: $(wildcard three*.txt)
	echo "$(date) $?" >> $@
```
Try it without any prerequisites present:

```console
$ make -f optional_prerequisites.makefile three
echo " " >> three
```

Et voila! The matched prerequisites truly are optional. But if any *are* present the target will be updated accordingly:

```console
$ cat > three33.txt
this number is thirty-three: 33
$ make -f optional_prerequisites.makefile three
echo " three33.txt" >> three
```

Here is the full `optional_prerequisites.makefile`:
```makefile
one: one.txt # non-optional
	sed 's/a/*/g' $< > $@
two: two*.txt # optional (a try)
	echo "$(date) $?" >> $@
three: $(optional three*.txt) # The REAL optional
	echo "$(date) $?" >> $@
```
