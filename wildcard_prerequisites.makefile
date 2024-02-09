one: one.txt
	sed 's/a/*/g' $< > $@
two: two*.txt
	echo "$(date) $?" >> $@
three: $(wildcard three*.txt)
	echo "$(date) $?" >> $@
four%: four%.txt
	sed 's/a/*/g' $< > $@
five%: five%*.txt
	echo "$(date) $?" >> $@
