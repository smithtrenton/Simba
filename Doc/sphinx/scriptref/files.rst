Working with Files
==================

Files in Simba are all *integers*, internal handles for Simba which on their
turn point to operating system files. Functions like CreateFile and OpenFile
return a file handle. You should not forget to close these when you no longer
need them.

CreateFile
----------

.. code-block:: pascal

    function CreateFile(const Path: string): Integer;

Create a file with *Path*. Raturns -1 on failure, otherwise returns the handle
to the file.

OpenFile
--------

.. code-block:: pascal

    function OpenFile(const Path: string; Shared: Boolean): Integer;

Opens file for reading. Opens shared if *Shared* is true.
Returns -1 on failure, otherwise returns the handle to the file.


RewriteFile
-----------

.. code-block:: pascal

    function RewriteFile(const Path: string; Shared: Boolean): Integer;

Opens file for rewriting. (File is cleared on open)
Opens shared if *Shared* is true.
Returns -1 on failure, otherwise returns the handle to the file.

AppendFile
----------

.. code-block:: pascal

    function AppendFile(const Path: string): Integer;

Opens file for writing (appending).
Returns -1 on failure, otherwise returns the handle to the file.

CloseFile
---------

.. code-block:: pascal

    procedure CloseFile(FileNum: Integer);

Close the file defined by *FileNum*. Never forget to close your files!

DeleteFile
----------

.. code-block:: pascal

    function DeleteFile(const Filename: string): Boolean;

Delete the file with name *Filename*. Returns true on success.

EndOfFile
---------

.. code-block:: pascal

    function EndOfFile(FileNum: Integer): Boolean;

Returns true if the end of the file has been reached.

FileSize
--------

.. code-block:: pascal

    function FileSize(FileNum: Integer): LongInt;

Returns the file size in characters.


ReadFileString
--------------

.. code-block:: pascal

    function ReadFileString(FileNum: Integer; var s: string; x: Integer):
    Boolean;

Read *x* characters into string *s* from file *FileNum*.
Returns true if the number of characters read equals *x*.

WriteFileString
---------------

.. code-block:: pascal

    function WriteFileString(FileNum: Integer; s: string): Boolean;

Writes *s* to file *FileNum*. Returns false on failure.


SetFileCharPointer
------------------

.. code-block:: pascal

    function SetFileCharPointer(FileNum, cChars, Origin: Integer): Integer;

*Seek* through the file. Set the cursor to *cChars* from *Origin*.

Origin can be any of these:

.. code-block:: pascal

    { File seek origins }
    FsFromBeginning = 0;
    FsFromCurrent   = 1;
    FsFromEnd       = 2;

FilePointerPos
--------------

.. code-block:: pascal

    function FilePointerPos(FileNum: Integer): Integer;

Returns the position of the *cursur* in the file.
(What character # you are at)

DirectoryExists
---------------

.. code-block:: pascal

    function DirectoryExists(const DirectoryName : string ) : Boolean;

Returns true if the directory exists.

CreateDirectory
---------------

.. code-block:: pascal

    function CreateDirectory(const DirectoryName : string) : boolean;

Creates a directory. Returns true on success.

FileExists 
-----------

.. code-block:: pascal

    function FileExists (const FileName : string ) : Boolean;

Returns true if the file exists.


ForceDirectories
----------------

.. code-block:: pascal

    function ForceDirectories(const dir : string) : boolean;

Creates multiple *nested* directories. Returns true on success.

GetFiles
--------

.. code-block:: pascal

    function GetFiles(const Path, Ext : string) : TStringArray;

Returns the files in the directory defined by *Path* with extension *Ext*.
You can also set Ext as '*' to return all files in Path.

GetDirectories
--------------

.. code-block:: pascal

    function GetDirectories(const path : string) : TStringArray;

Returns the directories in *path*.

WriteINI
--------

.. code-block:: pascal

    procedure WriteINI(const Section, KeyName, NewString, FileName: string);

The following example writes to a specific Line in a Specified INI File.

.. code-block:: pascal

    program WriteINIExample;

    Var Section, Keyname, NewString, FileName: String;

    begin
      Section := 'What subsection in the INI it is being Writen.';
      KeyName := 'Space in the specified Subsection in which you string is writen.';
      NewString := 'What your Writing into the INI file.';
      FileName := 'The Name of the INI File you are writing too.';
      WriteINI(Section, KeyName, NewString, ScriptPath + FileName);
    end.

.. note::

    ScriptPath will Automatically point the file finding to the same folder the script is saved in.

.. note::

    This procedure can be used in conjunction with ReadINI to saved Player Data for the next time a script is run.

ReadINI
-------

.. code-block:: pascal

    function ReadINI(const Section, KeyName, FileName: string): string;

The following example writes to a specific Line in a Specified INI File then Reads that line and prints it's findings.

.. code-block:: pascal

    program WriteINIReference;

    Var Section, Keyname, NewString, FileName: String;

    begin
      Section := 'What subsection in the INI it is being Writen.';
      KeyName := 'Space in the specified Subsection in which you string is writen.';
      NewString := 'What your Writing into the INI file.';
      FileName := 'The Name of the INI File you are writing too.';
      WriteINI(Section, KeyName, NewString, ScriptPath + FileName);
      Writeln(ReadINI(Section, KeyName, ScriptPath + FileName);
    end.

DeleteINI
---------

.. code-block:: pascal

    procedure DeleteINI(const Section, KeyName, FileName: string);

The following example deletes the specific line inside the specified INI file.

.. code-block:: pascal

    program DeleteINIExample;

    begin
      DeleteINI('Section', Key, File);
    end;

ExtractFileExt
--------------

.. code-block:: pascal

    function ExtractFileExt(const FileName: string): string;');   

Returns the file extension from file *Filename*.

DeleteDirectory
---------------

.. code-block:: pascal

    function DeleteDirectory(const Dir: String; const Empty: Boolean): Boolean;   

Deletes the directory *dir*, if Empty is true will delete the directorys contents else will not.
