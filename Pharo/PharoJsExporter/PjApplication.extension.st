Extension { #name : #PjApplication }

{ #category : #'*PharoJsExporter-App' }
PjApplication classSide >> appFolder [
	<pharoJsSkip>
	self ifInvalidFolder: appFolder do:[self setUpAppFolder].
	^appFolder	
]

{ #category : #'*PharoJsExporter-App' }
PjApplication classSide >> appFolder: anObject [
	<pharoJsSkip>
	appFolder := anObject
]

{ #category : #'*PharoJsExporter-App' }
PjApplication classSide >> appFullJsFileName [
	<pharoJsSkip>
	^self appFullJsFolderPath / self appJsFileName

]

{ #category : #'*PharoJsExporter-App' }
PjApplication classSide >> appFullJsFolderPath [
	<pharoJsSkip>
	self appJsSubFolder ifNotNil: [: subfolder|
		^self appFolder / subfolder 
	].
	^self appFolder

]

{ #category : #'*PharoJsExporter-App' }
PjApplication classSide >> appJsFileName [
	<pharoJsSkip>
	^ 'index.js'
]

{ #category : #'*PharoJsExporter-App' }
PjApplication classSide >> appJsSubFolder [
	<pharoJsSkip>
	"Subclass might return, e.g. 'js' if you want the javascript to be in the js sub-directory. 
	Useful, when you need to access the app/project folder that is different from the JS folder as with PhoneGap."
	^ nil
]

{ #category : #'*PharoJsExporter-App' }
PjApplication classSide >> exportApp [
	<pharoJsSkip>
	self exporterClass exportApp: self appClass
]

{ #category : #'*PharoJsExporter-App' }
PjApplication classSide >> exporterClass [
	<pharoJsSkip>
	^ PjFileExporter
]

{ #category : #'*PharoJsExporter-App' }
PjApplication classSide >> globalsPools [
	<pharoJsSkip>
	^ self allSharedPoolsRecursive select: #isJavascriptGlobalsPool
]

{ #category : #'*PharoJsExporter-App' }
PjApplication classSide >> ifInvalidFolder: folder do: aBlock [
	<pharoJsSkip>
	(folder isNil or: [folder exists not]) ifTrue: aBlock
]

{ #category : #'*PharoJsExporter-App' }
PjApplication classSide >> polyfill: aPolyfillClass onStream: aStream [
	<pharoJsSkip>

]

{ #category : #'*PharoJsExporter-App' }
PjApplication classSide >> setUpAppFolder [
	<pharoJsSkip>
	| folder |
	folder := UIManager default chooseDirectory: 'PharoJS: Folder for app ', self name, ' please?'.
	self ifInvalidFolder: folder do: [  
		^self error: 'PharoJS: Invalid folder for app ', self name].
	self appFolder: folder.
]