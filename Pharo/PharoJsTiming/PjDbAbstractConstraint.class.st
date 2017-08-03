"
I am an abstract class representing a system-maintainable relationship (or
""constraint"") between a set of variables. I supply a strength instance
variable; concrete subclasses provide a means of storing the constrained
variables and other information required to represent a constraint.

Instance variables:
	strength			the strength of this constraint <Strength>

"
Class {
	#name : #PjDbAbstractConstraint,
	#superclass : #Object,
	#instVars : [
		'strength'
	],
	#category : #'PharoJsTiming-DeltaBlue'
}

{ #category : #'add/remove' }
PjDbAbstractConstraint >> addConstraint [
	"Activate this constraint and attempt to satisfy it."

	self addToGraph.
	PjDbPlanner current incrementalAdd: self.
]

{ #category : #'add/remove' }
PjDbAbstractConstraint >> addToGraph [
	"Add myself to the constraint graph."

	self subclassResponsibility
]

{ #category : #planning }
PjDbAbstractConstraint >> chooseMethod: mark [
	"Decide if I can be satisfied and record that decision. The output of
	 the choosen method must not have the given mark and must have a
	 walkabout strength less than that of this constraint."

	self subclassResponsibility
]

{ #category : #'add/remove' }
PjDbAbstractConstraint >> destroyConstraint [
	"Deactivate this constraint, remove it from the constraint graph,
	 possibly causing other constraints to be satisfied, and destroy it."

	(self isSatisfied) ifTrue: [PjDbPlanner current incrementalRemove: self].
	self removeFromGraph.
	self release.
]

{ #category : #planning }
PjDbAbstractConstraint >> execute [
	"Enforce this constraint. Assume that it is satisfied."

	self subclassResponsibility
]

{ #category : #planning }
PjDbAbstractConstraint >> inputsDo: aBlock [
	"Assume that I am satisfied. Evaluate the given block on all my current
	 input variables."

	self subclassResponsibility
]

{ #category : #planning }
PjDbAbstractConstraint >> inputsKnown: mark [
	"Assume that I am satisfied. Answer true if all my current inputs are
	 known. A variable is known if either a) it is 'stay' (i.e. it is a
	 constant at plan execution time), b) it has the given mark (indicating
	 that it has been computed by a constraint appearing earlier in the
	 plan), or c) it is not determined by any constraint."

	self inputsDo:
		[: v |
		 ((v mark = mark) or: [(v stay) or: [v determinedBy == nil]]) ifFalse:
			[^false]].
	^true
]

{ #category : #queries }
PjDbAbstractConstraint >> isInput [
	"Normal constraints are not input constraints. An input constraint is
	 one that depends on external state, such as the mouse, the keyboard,
	 a clock, or some arbitrary piece of imperative code."

	^false
]

{ #category : #queries }
PjDbAbstractConstraint >> isSatisfied [
	"Answer true if this constraint is satisfied in the current solution."

	self subclassResponsibility
]

{ #category : #printing }
PjDbAbstractConstraint >> longPrintOn: aStream [

	| bindings |
	aStream nextPut: $(.
	self shortPrintOn: aStream.
	aStream space; nextPutAll: self strength printString.
	(self isSatisfied)
		ifTrue:
			[aStream cr; space; space; space.
			 self inputsDo:
				[: in | aStream nextPutAll: 'v', in asOop printString, ' '].
			aStream nextPutAll: '-> '.
			aStream nextPutAll: 'v', self output asOop printString]
		ifFalse:
			[aStream space; nextPutAll: 'UNSATISFIED'].
	aStream nextPut: $); cr.
]

{ #category : #planning }
PjDbAbstractConstraint >> markUnsatisfied [
	"Record the fact that I am unsatisfied."

	self subclassResponsibility
]

{ #category : #planning }
PjDbAbstractConstraint >> output [
	"Answer my current output variable. Raise an error if I am not
	 currently satisfied."

	self subclassResponsibility
]

{ #category : #printing }
PjDbAbstractConstraint >> printOn: aStream [

	self shortPrintOn: aStream
]

{ #category : #planning }
PjDbAbstractConstraint >> recalculate [
	"Calculate the walkabout strength, the stay flag, and, if it is 'stay',
	 the value for the current output of this constraint. Assume this
	 constraint is satisfied."

	self subclassResponsibility
]

{ #category : #'add/remove' }
PjDbAbstractConstraint >> removeFromGraph [
	"Remove myself from the constraint graph."

	self subclassResponsibility
]

{ #category : #planning }
PjDbAbstractConstraint >> satisfy: mark [
	"Attempt to find a way to enforce this (still unsatisfied) constraint.
	 If successful, record the solution, perhaps modifying the current
	 dataflow graph.  Answer the constraint that this constraint overrides,
	 if there is one, or nil, if there isn't."

	| overridden out |
	self chooseMethod: mark.
	(self isSatisfied)
		ifTrue:			"constraint can be satisfied"
			["mark inputs to allow cycle detection in addPropagate"
			 self inputsDo: [: in | in mark: mark].
			 out := self output.
			 overridden := out determinedBy.
			 (overridden == nil) ifFalse: [overridden markUnsatisfied].
			 out determinedBy: self.
			 (PjDbPlanner current addPropagate: self mark: mark) ifFalse:
				[self notify:
					('Cycle encountered adding:\   ',
					 self printString,
					 '\Constraint removed.') withCRs.
				 ^nil].
			 out mark: mark]
		ifFalse:			"constraint cannot be satisfied"
			[overridden := nil.
			 (strength sameAs: (PjDbStrength required)) ifTrue:
				[self notify: 'Failed to satisfy a required constraint']].
	^overridden
]

{ #category : #printing }
PjDbAbstractConstraint >> shortPrintOn: aStream [

	aStream nextPutAll: self class name, '(', self asOop printString, ')'.
]

{ #category : #accessing }
PjDbAbstractConstraint >> strength [
	"Answer my strength."

	^strength
]

{ #category : #accessing }
PjDbAbstractConstraint >> strength: strengthSymbol [
	"Set my strength."

	strength := PjDbStrength of: strengthSymbol.
]