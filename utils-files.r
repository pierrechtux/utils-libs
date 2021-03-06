REBOL [
	; -- Core Header attributes --
	title: "file and path related utility functions"
	file: %utils-files.r
	version: 1.0.5
	date: 2013-10-03
	author: "Maxim Olivier-Adlhoch"
	purpose: {Collection of generic, re-useable path and file handling functions.}
	web: http://www.revault.org/modules/utils-files.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'utils-files
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/utils-files.r

	; -- Licensing details  --
	copyright: "Copyright � 2013 Maxim Olivier-Adlhoch"
	license-type: "Apache License v2.0"
	license: {Copyright � 2013 Maxim Olivier-Adlhoch

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	
		http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.}

	;-  / history
	history: {
		v1.0.0 - 2012-02-21
			-creation
			-compiling previous code from other libraries
			
		v1.0.1 - 2013-01-09
			-renamed file to %utils-files.r  (S at the end) to make it more consistent with other utils libs.
			-renamed dir-part, file-part, ext-part  using newer R3 notation which adds *-of suffixe when extracting data.
			 so we now have path-of, filename-of, extension-of, old functions where COMMENTED and deprecated. 
			 only left the old names in comments for documentation purposes.

		v1.0.2 - 2013-09-12
			-license changed to Apache v2
			
		v1.0.3 - 2013-09-25
			-fixed DIR-TREE 
				*/ABSOLUTE now also works for folder paths,  
				*/IGNORE block now works on root-relative paths, 
				*fixed typo which crashed functions
		v1.0.4 - 2013-10-01
			-changed 'DIR-PART  to  'DIRECTORY-OF
			-deprecated 'DIR-PART
			
		v1.0.5 - 2013-10-03
			- 'DIRECTORY-OF  'EXTENSION-OF  &  'FILENAME-OF  are now  NONE! transparent and overhauled.
			- added tests
			- changed spaced indentation to make it tabbed.
			- 'SUBSTITUTE-FILE is now none transparent (on both inputs!) and re-implemented using 'DIRECTORY-OF  &  'FILENAME-OF
			- *many* odd case bugs fixed with overhauls of above functons.
}
	;-  \ history

	;-  / documentation
	documentation: ""
	;-  \ documentation
]




;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'utils-files
;
;--------------------------------------


slim/register [

	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;- 
	;- FUNCTIONS
	;- 
	;-----------------------------------------------------------------------------------------------------------
	copy*: :copy  ; needed for /copy refinement
	
	
	
	;-------------------
	;-    as-file()
	;--------------------------
	;
	; (prototype, might be a bit unstable with weird paths)
	;
	; universal path fixup method, allows any combination of file! string! types written as 
	; rebol or os filepaths.
	;
	; also cleans up // path items (doesnt fix /// though).
	;
	; NOTE: this function cannot fully support url-encoded strings, since there
	;   is a bug in path notation which doesn't properly convert string! to/from path!.
	; 
	;   for example the space (%20), when it is the first character of the string, will stick as "%20" 
	;   (and become impossible to decipher when probing the path)
	;   instead of becoming a space character.
	; 
	;   We take for granted that the first '%' prefix (when given a string!), is a path prefix and simply remove it.
	;
	;   Be careful if providing UNC paths, as handling of these is not specifically managed.
	;   furthermore, handling of these within Rebol, may change from one version to the next.
	;-----
	as-file: func  [
		path [ string! file! ]
	][
		path: switch type/word path [
			string! [
				to-rebol-file replace/all any [
					all [
						path/1 = #"%"
						next path
					]
					path
				] "//" "/"
				
			]
			
			file! [
				path
			]
		]   
		
		path
	]
	

		
	;--------------------------
	;-     directory-of()
	;--------------------------
	; purpose:  get the directory (folder) part of a path, if any.
	;
	; inputs:   a file! datatype
	;
	; tests:
	;	test-group [file! directory-of utils-files.r] []
	;		[ %/root/path/ = directory-of %/root/path/ ]
	;		[ %/root/path/ = directory-of %/root/path/file ]
	;		[ %/           = directory-of %/root ]
	;		[ %./          = directory-of %./ ]
	;		[ %./          = directory-of %./file.ext ]
	;		[ none         = directory-of %file.ext ]
	;		[ none         = directory-of %.ext ]
	;		[ none         = directory-of none ]
	;		[ %./          = directory-of %./file.ext ]
	;		[ error? try [ filename-of "test" ]]
	;	end-group
	;
	; deprecated names:
		dir-part: 
	;-----------------
	directory-of: funcl [
		path [file! none!]
	][
		all [
			path
			file: find/tail/last path "/"
			copy/part path file
		]
	]



	;--------------------------
	;-     filename-of()
	;--------------------------
	; purpose:  get the filename part of a path, if any.
	;
	; inputs:   a file! datatype
	;
	; returns:  a filename of file! type or none!
	;
	; notes:    returns none when there is no file in the path.
	;           if the filename is only an extension, that is returned.
	;
	;           now none transparent (as of v1.0.5)
	;
	; tests:
	;	test-group [file! filename-of utils-files.r] []
	;		[ none       = filename-of %/root/path/ ]
	;		[ %file      = filename-of %/root/path/file ]
	;		[ %root      = filename-of %/root ]
	;		[ none       = filename-of %./ ]
	;		[ %file.ext  = filename-of %./file.ext ]
	;		[ %file.ext  = filename-of %file.ext ]
	;		[ %.ext      = filename-of %.ext ]
	;		[ none       = filename-of none ]
	;		[ error? try [ filename-of "test" ]]
	;	end-group
	;
	; deprecated names:
		file-part:
	;--------------------------
	filename-of: funcl [
		path [file! none!]
	][
		all [
			path
			file: any [
				find/tail/last path "/"
				path
			]
			not empty? file
			copy file
		]
	]
	

	
	;--------------------------
	;-     extension-of()
	;--------------------------
	; purpose:  returns the extension part of a file path
	;
	; inputs:   a file path
	;
	; returns:  -the extension of the file, or none, if its a directory (even if it contains a "." in the path)
	;           -we silently ignore none inputs by returning none
	;
	; notes:    -we rely only on the file path given, not its actual type on disk to verify if the input is indeed a directory.
	;           -we return an offset from the filename of the given path.
	;
	; tests:   
	;	test-group [file! extension-of utils-files.r] []
	;		[ none       = extension-of %/root/path/ ]
	;		[ none       = extension-of %/root/path/file ]
	;		[ none       = extension-of %/root ]
	;		[ none       = extension-of %./ ]
	;		[ %r         = extension-of %./file.r ]
	;		[ %r         = extension-of %file.r ]
	;		[ %r         = extension-of %.r ]
	;		[ none       = extension-of none ]
	;		[ %longext   = extension-of %/root/path/file.longext ]
	;		[ error? try [ extension-of "test" ]]
	;	end-group
	; 
	; deprecated names:
		ext-part: 
	;--------------------------
	extension-of: funcl [
		path [file! none!]
	][
		all [
			path
			file: filename-of path  ; 'FILENAME-OF does a copy, so we don't have to.
			find/last/tail file "." ; returns none when not found.
		]
			
	]
	

	
	
	;--------------------------
	;-     substitute-file()
	;--------------------------
	; purpose:  given two files, will take the filename from the second and put in the first, in place.
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    modifies first file
	;
	; tests:    
	;	test-group [file! substitute-file utils-files.r] []
	;		;---
	;		; simple tests
	;		;---
	;		[ %/root/path/b       = substitute-file %/root/path/a  %/root/path/b ]
	;		[ %/root/path/b       = substitute-file %/root/path/ %b]
	;		[ %/b                 = substitute-file %/ %b]
	;		[ %b                  = substitute-file %a %b]
	;		[ %/                  = substitute-file %/ %/test/]
	;		[ %/a/                = substitute-file %/a/ %/b/]
	;
	;		;---
	;		; none-transparency tests
	;		;---
	;		[ %/root/path/        = substitute-file %/root/path/a  none ]
	;		[ %/root/path/        = substitute-file %/root/path/   none ]
	;		[ %b                  = substitute-file none %/path/to/b ]
	;		[ %b                  = substitute-file none %b ]
	;		[ none                = substitute-file none none ]
	;
	;		;---
	;		; test /copy refinement
	;		;---
	;		[ a: %/path/to/a  b: %/root/to/b    c: substitute-file a b  all [ ( same? a c )   ( c = %/path/to/b ) ]  ]
	;		[ a: %/path/to/a  b: %/path/to/b    c: substitute-file/copy a b  not same? a c]
	;
	;		;---
	;		; negative tests
	;		;---
	;		[ error? try [ substitute-file "test" "ddd" ]]
	;	end-group
	;--------------------------
	substitute-file: funcl [
		file-a [ file! none! ]
		file-b [ file! none! ]
		/copy "Returns a new version of file-a, instead of modifying it."
	][
		dir: directory-of file-a
		file: filename-of file-b
	
		;---
		; if copy is required, we simply copy the dir within file-a, we also set dir as a reference to the file-a data
		all [
			dir 
			not copy 
			dir: append clear file-a dir
		]
		
		any [
			all [
				dir file 
				append dir file
			]
			
			dir
			file
		]
		
	]
	
	
	
	;-------------------
	;-     is-dir?()
	;-----
	is-dir?: func [
		path [string! file!]
	][
		path: to-string path
		replace/all path "\" "/"
		
		all [
			path: find/last/tail path "/"
			tail? path
		]
	]
	

	;-------------------
	;-     is-file?()
	;-----
	is-file?: func [
		path [string! file!]
	][
		not is-dir? path
	]
	
	
	;-----------------
	;-     dir-tree()
	;-----------------
	dir-tree: funcl [
		path [file!]
		/root rootpath [file! none!]
		/absolute "returns absolute paths"
		/ignore i-blk [block! file!] "if the path is within the ignore paths block, we reply an empty block, paths must be given as a complete path including %./ or else is ignored."
		;/local list item data subpath dirpath rval
	][
		rval: copy []
		
		i-blk: any [i-blk []]
		i-blk: compose [(i-blk)]
		
		
		either root [
			unless exists? rootpath [
				to-error rejoin [ "compiler/dir-tree()" path " does not exist" ]
			]
		][
			either is-dir? path [
				rootpath: path
				path: %./
			][
				to-error rejoin [ "compiler/dir-tree()" path " MUST be a directory." ]
			]
		]
		
		dirpath: clean-path append copy rootpath path
		
		unless find i-blk path [
			either is-dir? dirpath [
				; list directory content
				list: read dirpath
				
				; append that path to the file list
				either absolute [
					append rval clean-path join rootpath path
				][
					append rval path
				]
				;append rval path
				
				foreach item list [
					subpath: join path item
					
					; list content of this new path item (files are returned directly)
					either absolute [
						data: dir-tree/root/absolute/ignore subpath rootpath i-blk
					][
						data: dir-tree/root/ignore subpath rootpath i-blk
					]
					;if (length? data) > 0 [
						insert tail rval data
					;]
				]
			][
				if absolute [
					path: clean-path join rootpath path
				]
				; when the path is a file, just return it, it will be compiled with the rest.
				rval: path
			]
		]
		
		if block? rval [
			rval: new-line/all  head sort rval true
		]
		
		rval
	]
	
	
	
	;--------------------------
	;-     newer?()
	;--------------------------
	; purpose:  given one or more sets of files (possibly trees) 
	;
	; inputs:   pairs of source + reference files
	;
	; returns:  block of all files which are more recent (in content or date) (note we only return the source files)
	;           none, when block would be empty
	;
	; notes:    if destination doesn't yet exist, then we return true.
	;
	; tests:    
	;--------------------------
	newer?: funcl [
		paths [block!] "pairs of source + reference files"
	][
		vin "newer?()"
		vprobe what-dir
		paths: remove-each [src dest] copy paths [
			vprint "--"
			v?? src
			v?? dest
			src: clean-path src
			dest: clean-path dest
			v?? src
			v?? dest
			vprobe info? src
			vprobe info? dest
			unless exists? src [
				probe clean-path src
				to-error "'NEWER? :: source file doesn't exist (yet?)"
			]
			all [
				; new file
				exists? dest
				
				; updated-file
				( modified? src ) <= ( modified? dest )
			]
		]
		vout
		
		;----
		; return none when nothing is newer
		; return only source files (we ignore reference files in return)
		first reduce [
			all [
				not empty? paths
				extract paths 2
			]
			paths: none
		]   
	]
	
	
	
	
	
	
	
	
]

