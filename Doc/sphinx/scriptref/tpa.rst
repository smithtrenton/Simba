.. _scriptref_tpa:

TPointArray Functions
=====================

Quicksort
---------

.. code-block:: pascal

    procedure Quicksort(var Arr : TIntegerArray);

Sorts a TIntegerArray using the Quicksort algorithm


tSwap
-----

.. code-block:: pascal

    procedure tSwap(var a, b: TPoint);

Swaps the values of a and b around

The following example switches point P with point P2. You can run the example
for a demonstration. It will print before the swap and after the swap to
illustrate the change.

.. code-block:: pascal

    program tSwapExample;

    var P, P2: Tpoint;

    begin
      P := Point(111, 111);
      P2 := Point(222, 222);
      writeln('P := ' + tostr(P));
      writeln('P2 := ' + tostr(P2));
      tSwap(P, P2);
      writeln('P := ' + tostr(P));
      writeln('P2 := ' + tostr(P2));
    end.


tpaSwap
-------

.. code-block:: pascal

    procedure tpaSwap(var a, b: TPointArray);

Swaps the values of a and b around


SwapE
-----

.. code-block:: pascal

    procedure SwapE(var a, b: Extended);

Swaps the values of a and b around


RAaSTPAEx
---------

.. code-block:: pascal

    procedure RAaSTPAEx(var a: TPointArray; const w, h: Integer);

Leaves one point per box with side lengths W and H to the TPA

RAaSTPA
-------

.. code-block:: pascal

    procedure RAaSTPA(var a: TPointArray; const Dist: Integer);

Leaves one point per box with the side length Dist


NearbyPointInArrayEx
--------------------

.. code-block:: pascal

    function NearbyPointInArrayEx(const P: TPoint; w, h:Integer;const  a: TPointArray): Boolean;

Returns true if the point P is near a point in the TPA a with the


NearbyPointInArray
------------------

.. code-block:: pascal

    function NearbyPointInArray(const P: TPoint; Dist:Integer;const  a: TPointArray): Boolean;

Returns true if the point P is near a point in the TPA a with the


QuickTPASort
------------

.. code-block:: pascal

    procedure QuickTPASort(var A: TIntegerArray; var B: TPointArray; iLo, iHi: Integer; SortUp: Boolean);


QuickATPASort
-------------

.. code-block:: pascal

    procedure QuickATPASort(var A: TIntegerArray; var B: T2DPointArray; iLo, iHi: Integer; SortUp: Boolean);


SortTPAFrom
-----------

.. code-block:: pascal

    procedure SortTPAFrom(var a: TPointArray; const From: TPoint);

Sorts the TPA a from the TPoint From


SortATPAFrom
------------

.. code-block:: pascal

    procedure SortATPAFrom(var a: T2DPointArray; const From: TPoint);

Loops though each index of the T2DPointArray sorting each tpa from the TPoint


SortATPAFromFirstPoint
----------------------

.. code-block:: pascal

    procedure SortATPAFromFirstPoint(var a: T2DPointArray; const From: TPoint);

Sorts the T2DPointArray from the TPoint, based from the first point in each TPointArray


SortATPAFromMidPoint
--------------------

.. code-block:: pascal

    procedure SortATPAFromMidPoint(var a: T2DPointArray; const From: TPoint);

Sorts the T2DPointArray from the TPoint, based from the middle point in each TPointArray


SortATPAFromFirstPointX
-----------------------

.. code-block:: pascal

    procedure SortATPAFromFirstPointX(var a: T2DPointArray; const From: TPoint);

Sorts the T2DPointArray from the TPoint, based from the first point X value in each TPointArray


SortATPAFromFirstPointY
-----------------------

.. code-block:: pascal

    procedure SortATPAFromFirstPointY(var a: T2DPointArray; const From: TPoint);

Sorts the T2DPointArray from the TPoint, based from the first point Y value in each TPointArray


InvertTPA
---------

.. code-block:: pascal

    procedure InvertTPA(var a: TPointArray);

Reverses the TPA


InvertATPA
----------

.. code-block:: pascal

    procedure InvertATPA(var a: T2DPointArray);

Reverses the T2dPointArray


MiddleTPAEx
-----------

.. code-block:: pascal

    function MiddleTPAEx(const TPA: TPointArray; var x, y: Integer): Boolean;

Stores the middle point from the TPA in x and y

The following example will find the Colors and make a TPA then give you the x and y coordinates for the middle of the TPA.

.. code-block:: pascal

    program MiddleTPAExExample;

    var
      TPA: TPointArray;
      x, y: Integer;

    begin
      findcolors(TPA, 205, 0, 0, 100, 100);
      MiddleTPAEx(TPA, x, y);
      Mouse(x, y, 0, 0, 1);
    end.


MiddleTPA
---------

.. code-block:: pascal

    function MiddleTPA(const tpa: TPointArray): TPoint;

Returns the middle TPA in the result

The following example like the previous one gives you the coordinates for the Middle of the TPA, but it returns it with the result being a TPoint.

.. code-block:: pascal

    program MiddleTPAExample;

    var
      TPA: TPointArray;
      P: TPoint;

    begin
      findcolors(TPA, 205, 0, 0, 100, 100);
      P := MiddleTPAEx(TPA);
      Mouse(P.x, P.y, 0, 0, 1);
    end.


MedianTPAEx
-----------

.. code-block:: pascal

    procedure MedianTPAEx(var tpa: TPointArray; out x, y: integer);

Finds the point closest to the middle of the TPointArray, returns the TPoint in parameter x and y.


MedianTPA
---------

.. code-block:: pascal

    function MedianTPA(var tpa: TPointArray): TPoint;

Returns the point closest to the middle of the TPointArray.


SortATPASize
------------

.. code-block:: pascal

    procedure SortATPASize(var a: T2DPointArray; const BigFirst: Boolean);

Sorts the T2dPointArray from largest to smallest if BigFirst is true or smallest to largest if BigFirst is false

The following Example Sorts the ATPA from largest to smallest.

.. code-block:: pascal

    program SortATPASizeExample;

    var
      TPA: TPointArray;
      P: TPoint;

    begin
      findcolors(TPA, 205, 0, 0, 100, 100);
      ATPA := TPAtoATPA(TPA, 10);
      SortATPASize(ATPA, true);
    end.

SortATPAFromSize
----------------

.. code-block:: pascal

    procedure SortATPAFromSize(var a: T2DPointArray; const Size: Integer; CloseFirst: Boolean);

Sorts the T2DPointArray from Size by the closest first if CloseFirst is true


FilterTPAsBetween
-----------------

.. code-block:: pascal

    procedure FilterTPAsBetween(var atpa: T2DPointArray; const minLength, maxLength: integer);

Loops though each index of the T2DPointArray, removing the TPointArrays if their length falls beetween minLength and MaxLength.


InIntArrayEx
------------

.. code-block:: pascal

    function InIntArrayEx(const a: TIntegerArray; var Where: Integer; const Number: Integer): Boolean;

Returns true if Number was found in the TIntegerArray a and returns its location in Where


InIntArray
----------

.. code-block:: pascal

    function InIntArray(const a: TIntegerArray; Number: Integer): Boolean;

Returns true if Number is found in the TintegerArray a


ClearSameIntegers
-----------------

.. code-block:: pascal

    procedure ClearSameIntegers(var a: TIntegerArray);

Deletes the indexes in the TintegerArray a which are duplicated


ClearSameIntegersAndTPA
-----------------------

.. code-block:: pascal

    procedure ClearSameIntegersAndTPA(var a: TIntegerArray; var p: TPointArray);

Deletes the indexes in the TIntegerArray a and TPointArray p which are duplicated


SplitTPAEx
----------

.. code-block:: pascal

    function SplitTPAEx(const arr: TPointArray; w, h: Integer): T2DPointArray;

Splits the points with max X and Y distances W and H to their own TPointArrays;


SplitTPA
--------

.. code-block:: pascal

    function SplitTPA(const arr: TPointArray; Dist: Integer): T2DPointArray;

Splits the points with max distance Dist to their own TPointArrays


ClusterTPAEx
------------

.. code-block:: pascal

    function ClusterTPAEx(const TPA: TPointArray; width, height: Integer): T2DPointArray;

Splits the points to their own TPointArrays if they fall outside of 'width' and 'height' bounds.
An alternative to SplitTPAEx, will be extremely fast compared to SplitTPAEx with a width/height less than 100.


ClusterTPA
----------

.. code-block:: pascal

    function ClusterTPA(const TPA: TPointArray; dist: Extended): T2DPointArray;

Splits the points with max distance 'dist' to their own TPointArrays.
An alternative to SplitTPA, will be extremely fast compared to SplitTPA with a distance less than 100.


FloodFillTPA
------------

.. code-block:: pascal

    function FloodFillTPA(const TPA : TPointArray) : T2DPointArray;


FilterPointsPie
---------------

.. code-block:: pascal

    procedure FilterPointsPie(var Points: TPointArray; const SD, ED, MinR, MaxR: Extended; Mx, My: Integer);

Removes the points that are in the TPointArray Points that are not within the the degrees SD (Strat Degrees) and 
    ED (End Degrees) and the radius' MinR (Min Radius) and MaxR (Max Radius) from the origin Mx and My


FilterPointsLine
----------------

.. code-block:: pascal

    procedure FilterPointsLine(var Points: TPointArray; Radial: Extended; Radius, MX, MY: Integer);

Returns the result in the TPointArray Points. Returns the points from the TPointArray Points that are on the line Radial from the center mx, my that is with the radius Radius


FilterPointsDist
----------------

.. code-block:: pascal

    procedure FilterPointsDist(var Points: TPointArray; const MinDist, MaxDist: Extended; Mx, My: Integer);

Removes the points from the TPointArray Points that are not within the radius MinDist (Min Distance) and MaxDist
    from the origin Mx and My


FilterPointsBox
---------------

.. code-block:: pascal

    procedure FilterPointsBox(var points: TPointArray; x1, y1, x2, y2: integer);

Removes the points from the TPointArray that are not within the bounds of the box.


GetATPABounds
-------------

.. code-block:: pascal

    function GetATPABounds(const ATPA: T2DPointArray): TBox;

Returns the boundaries of the T2DPointArray ATPA as a TBox


GetTPABounds
------------

.. code-block:: pascal

    function GetTPABounds(const TPA: TPointArray): TBox;

Returns the boundaries of the TPointArray TPA as a TBox


FindTPAinTPA
------------

.. code-block:: pascal

    function FindTPAinTPA(const SearchTPA, TotalTPA: TPointArray; var Matches: TPointArray): Boolean;

Looks for the TPoints from SearchTPA inside TotalTPA and stores the matches inside the TPointArray Matches


GetSamePointsATPA
-----------------

.. code-block:: pascal

    function GetSamePointsATPA(const  ATPA : T2DPointArray; var Matches : TPointArray) : boolean;

Finds duplicate Points inside the T2DPointArray ATPA and stores the results inside the TPointArray Matches


FindTextTPAinTPA
----------------

.. code-block:: pascal

    function FindTextTPAinTPA(Height : integer;const  SearchTPA, TotalTPA: TPointArray; var Matches: TPointArray): Boolean;

Looks for the TPoints from SearchTPA inside TotalTPA with a maximum y distance of Height and stores the matches inside the TPointArray Matches


SortCircleWise
--------------

.. code-block:: pascal

    procedure SortCircleWise(var tpa: TPointArray; const cx, cy, StartDegree: Integer; SortUp, ClockWise: Boolean);

Sorts the TPointArray tpa from the point cx, cy if Sortup is true. Starting at StartDegree going clockwise if Clockwise is True 


LinearSort
----------

.. code-block:: pascal

    procedure LinearSort(var tpa: TPointArray; cx, cy, sd: Integer; SortUp: Boolean);

Sorts the TPointArray tpa from cx, cy if Sortup is true on the degree angle sd


RotatePoint
-----------

.. code-block:: pascal

    function RotatePoint(Const p: TPoint; angle, mx, my: Extended): TPoint;

Rotates the TPoint p around the center mx, my with the angle


ChangeDistPT
------------

.. code-block:: pascal

    function ChangeDistPT(const PT : TPoint; mx,my : integer; newdist : extended) : TPoint;

Returns a TPoint with the distance newdist from the point mx, my based on the position of the TPoint TP


ChangeDistTPA
-------------

.. code-block:: pascal

    function ChangeDistTPA(var TPA : TPointArray; mx,my : integer; newdist : extended) : boolean;

Returns the result in the TPointArray TPA with the distance newdist from mx, my based on the current position TPA


FindGapsTPA
-----------

.. code-block:: pascal

    function FindGapsTPA(const TPA: TPointArray; MinPixels: Integer): T2DPointArray;

Finds the possible gaps in the TPointArray TPA and results the gaps as a T2DPointArray. Considers as a gap if the gap length is >= MinPixels


RemoveDistTPointArray
---------------------

.. code-block:: pascal

    function RemoveDistTPointArray(x, y, dist: Integer;const  ThePoints: TPointArray; RemoveHigher: Boolean): TPointArray;

Finds the possible gaps in the TPointArray TPA and removes the gaps. Considers as a gap if the gap length is >= MinPixels


CombineTPA
----------

.. code-block:: pascal

    function CombineTPA(const Ar1, Ar2: TPointArray): TPointArray;

Attaches the TPointArray Ar2 onto the end of Ar1 and returns it as the result


ReArrangeandShortenArrayEx
--------------------------

.. code-block:: pascal

    function ReArrangeandShortenArrayEx(const a: TPointArray; w, h: Integer): TPointArray;

Results the TPointArray a with one point per box with side lengths W and H left


ReArrangeandShortenArray
------------------------

.. code-block:: pascal

    function ReArrangeandShortenArray(const a: TPointArray; Dist: Integer): TPointArray;

Results the TPointArray a with one point per box with side length Dist left


TPAtoATPAEx
-----------

.. code-block:: pascal

    function TPAtoATPAEx(const TPA: TPointArray; w, h: Integer): T2DPointArray;

Splits the TPA to boxes with sidelengths W and H and results them as a T2DPointArray


TPAtoATPA
---------

.. code-block:: pascal

    function TPAtoATPA(const TPA: TPointArray; Dist: Integer): T2DPointArray;

Splits the TPA to boxes with sidelength Dist and results them as a T2DPointArray


CombineIntArray
---------------

.. code-block:: pascal

    function CombineIntArray(const Ar1, Ar2: TIntegerArray): TIntegerArray;

Attaches the TIntegerArray Ar2 onto the end of Ar1 and returns it as the result


MergeATPA
---------

.. code-block:: pascal

    function MergeATPA(const ATPA : T2DPointArray)  : TPointArray;

Combines all the TPointArrays from the T2DPointArray ATPA into the result


AppendTPA
---------

.. code-block:: pascal

    procedure AppendTPA(var TPA: TPointArray; const ToAppend: TPointArray);

Attaches the TPointArray ToAppend onto the end of TPA


TPAFromLine
-----------

.. code-block:: pascal

    function TPAFromLine(const x1, y1, x2, y2: Integer): TPointArray;

Returns a TPointArray of a line specified by the end points x1,y1 and x2,y2.       


EdgeFromBox
-----------

.. code-block:: pascal

    function EdgeFromBox(const Box: TBox): TPointArray;

Creates a TPointArray from the edge of the TBox box


TPAFromBox
----------

.. code-block:: pascal

    function TPAFromBox(const Box : TBox) : TPointArray;

Create a TPointArray from the top left and the bottom right of the TBox Box


TPAFromEllipse
--------------

.. code-block:: pascal

    function TPAFromEllipse(const CX, CY, XRadius, YRadius : Integer) : TPointArray;

Creates and returns a TPointArray of the outline of a ellipse 


TPAFromCircle
-------------

.. code-block:: pascal

    function TPAFromCircle(const CX, CY, Radius : Integer) : TPointArray;

Creates and returns a TPointArray of a circle, around the center point (CX, CY), with the size determined by Radius


TPAFromPolygon
--------------

.. code-block:: pascal

    function TPAFromPolygon(const shape: TPointArray) : TPointArray;

Returns polygon as a TPointArray from a shape, which can be working either as
an array of main points OR border points. note: The order of the points are important.        

.. code-block:: pascal

  program TPAFromPolygonExample;

  var
    tpa, shape: TPointArray;
    bmp: integer;

  begin
    tpa := [point(70,90), point(185,90), point(185,116), point(70,116),
            point(70,140), point(35,105), point(70,70)];

    shape := TPAFromPolygon(tpa);

    bmp := createBitmap(230, 200);
    drawTPABitmap(bmp, shape, 255);

    displayDebugImgWindow(230, 200);
    drawBitmapDebugImg(bmp);
  end.  


FillEllipse
-----------

.. code-block:: pascal

    procedure FillEllipse(var a: TPointArray);

Fills a ellipse, suggested to be used with TPAFromEllipse or TPAFromCircle


RotatePoints
------------

.. code-block:: pascal

    function RotatePoints(Const P: TPointArray; A, cx, cy: Extended): TPointArray ;

Rotates the TPointArray P around the center cx, cy with the angle a


FindTPAEdges
------------

.. code-block:: pascal

    function FindTPAEdges(const p: TPointArray): TPointArray;

Returns a TPointArray of the edge points of the TPointArray p


ClearTPAFromTPA
---------------

.. code-block:: pascal

    function ClearTPAFromTPA(const arP, ClearPoints: TPointArray): TPointArray;

Removes the points in TPointArray ClearPoints from arP


ReturnPointsNotInTPA
--------------------

.. code-block:: pascal

    function ReturnPointsNotInTPA(Const TotalTPA: TPointArray; const Box: TBox): TPointArray;

All the points from the TPointArray TotalTPA that are not in the TBox Box are returned in the TPointArray Res


PointInTPA
----------

.. code-block:: pascal

    function PointInTPA(p: TPoint;const  arP: TPointArray): Boolean;

Returns true if the TPoint p is found in the TPointArray arP


ClearDoubleTPA
--------------

.. code-block:: pascal

    procedure ClearDoubleTPA(var TPA: TPointArray);

Deletes duplicate TPAs in the TPointArray TPA


TPACountSort
------------

.. code-block:: pascal

    procedure TPACountSort(Var TPA: TPointArray;const max: TPoint;Const SortOnX : Boolean);


TPACountSortBase
----------------

.. code-block:: pascal

    procedure TPACountSortBase(Var TPA: TPointArray;const maxx, base: TPoint; const SortOnX : Boolean);


InvertTIA
---------

.. code-block:: pascal

    procedure InvertTIA(var tI: TIntegerArray);

Reverses the TIntegerArray tI


SumIntegerArray
---------------

.. code-block:: pascal

    function SumIntegerArray(const Ints : TIntegerArray): Integer;

Retuns the sum of all the integers in the TIntegerArray Ints


AverageTIA
----------

.. code-block:: pascal

    function AverageTIA(const tI: TIntegerArray): Integer;

Gives an average of the sum of the integers in the TIntegerArray tI


AverageExtended
---------------

.. code-block:: pascal

    function AverageExtended(const tE: TExtendedArray): Extended;

Gives an average of the sum of the extendeds in the TExtendedArray tI


SplitTPAExWrap
--------------

.. code-block:: pascal

    procedure SplitTPAExWrap(const arr: TPointArray; w, h: Integer; var res : T2DPointArray);

Splits the points with max X and Y distances W and H to their and returns the result in the T2DPointArray Res


SplitTPAWrap
------------

.. code-block:: pascal

    procedure SplitTPAWrap(const arr: TPointArray; Dist: Integer; var res: T2DPointArray);

Splits the points with max distance Dist to their own TPointArrays and returns the result in the T2DPointArray Res


FindGapsTPAWrap
---------------

.. code-block:: pascal

    procedure FindGapsTPAWrap(const TPA: TPointArray; MinPixels: Integer; var Res : T2DPointArray);

Finds the possible gaps in the TPointArray TPA and the result is returned in the T2DPointArray Res. Considers as a gap if the gap length is >= MinPixels


RemoveDistTPointArrayWrap
-------------------------

.. code-block:: pascal

    procedure RemoveDistTPointArrayWrap(x, y, dist: Integer;const  ThePoints: TPointArray; RemoveHigher: Boolean; var Res :  TPointArray);

Finds the possible gaps in the TPointArray TPA and removes the gaps. Considers as a gap if the gap length is >= MinPixels and returns the result in the TPointArray Res


CombineTPAWrap
--------------

.. code-block:: pascal

    procedure CombineTPAWrap(const Ar1, Ar2: TPointArray; var Res :  TPointArray);

Attaches the TPointArray Ar2 onto the end of Ar1 and returns the result in the TPointArray Res


ReArrangeandShortenArrayExWrap
------------------------------

.. code-block:: pascal

    procedure ReArrangeandShortenArrayExWrap(const a: TPointArray; w, h: Integer; var Res :  TPointArray);

Results the TPointArray a with one point per box with side lengths W and H left and puts the result in Res


ReArrangeandShortenArrayWrap
----------------------------

.. code-block:: pascal

    procedure ReArrangeandShortenArrayWrap(const a: TPointArray; Dist: Integer; var Res :  TPointArray);

Results the TPointArray a with one point per box with side length Dist left and puts the result in Res


TPAtoATPAExWrap
---------------

.. code-block:: pascal

    procedure TPAtoATPAExWrap(const TPA: TPointArray; w, h: Integer; var Res :  T2DPointArray);

Splits the TPA to boxes with sidelengths W and H and results them as a T2DPointArray in Res


TPAtoATPAWrap
-------------

.. code-block:: pascal

    procedure TPAtoATPAWrap(const TPA: TPointArray; Dist: Integer; var Res :  T2DPointArray);

Splits the TPA to boxes with sidelength Dist and results them as a T2DPointArray in Res


CombineIntArrayWrap
-------------------

.. code-block:: pascal

    procedure CombineIntArrayWrap(const Ar1, Ar2: TIntegerArray; var Res :  TIntegerArray);

Attaches the TIntegerArray Ar2 onto the end of Ar1 and returns it in the TIntegerArray Res


ReturnPointsNotInTPAWrap
------------------------

.. code-block:: pascal

    procedure ReturnPointsNotInTPAWrap(Const TotalTPA: TPointArray; const Box: TBox; var Res :  TPointArray);

All the points from the TPointArray TotalTPA that are not in the TBox Box are returned in the TPointArray Res


MergeATPAWrap
-------------

.. code-block:: pascal

    procedure MergeATPAWrap(const ATPA : T2DPointArray; var Res: TPointArray);

Combines all the TPointArrays from the T2DPointArray ATPA into the TPointArray Res


TPAFromBoxWrap
--------------

.. code-block:: pascal

    procedure TPAFromBoxWrap(const Box : TBox; var Res : TPointArray);

Create a TPointArray from the top left and the bottom right of the TBox Box and returns the result in Res


RotatePointsWrap
----------------

.. code-block:: pascal

    procedure RotatePointsWrap(Const P: TPointArray; A, cx, cy: Extended; var Res :  TPointArray);

Rotates the TPointArray P around the center cx, cy with the angle a and returns the result in Res


FindTPAEdgesWrap
----------------

.. code-block:: pascal

    procedure FindTPAEdgesWrap(const p: TPointArray; var Res :  TPointArray);

Returns a TPointArray of the edge points of the TPointArray p and returns the result in the TPointArray Res


ClearTPAFromTPAWrap
-------------------

.. code-block:: pascal

    procedure ClearTPAFromTPAWrap(const arP, ClearPoints: TPointArray;  var Res :  TPointArray);

Removes the points in TPointArray ClearPoints from arP and returns the results in Res


SameTPA
-------

.. code-block:: pascal

    function SameTPA(const aTPA, bTPA: TPointArray): Boolean;

Returns true if the TPointArray aTPA is the same as bTPA 


TPAInATPA
---------

.. code-block:: pascal

    function TPAInATPA(const TPA: TPointArray;const  InATPA: T2DPointArray; var Index: LongInt): Boolean;

Returns true if the TPointArray TPA is found in the T2DPointArray InATPA and stores the index in Index


OffsetTPA
---------

.. code-block:: pascal

    procedure OffsetTPA(var TPA : TPointArray; const Offset : TPoint);

Offsets all the TPAs int the TPointArray TPA but the TPoint Offset


OffsetATPA
----------

.. code-block:: pascal

    procedure OffsetATPA(var ATPA : T2DPointArray; const Offset : TPoint);

Offsets all the TPAs int the T2DPointArray ATPA but the TPoint Offset


CopyTPA
-------

.. code-block:: pascal

    function CopyTPA(const TPA : TPointArray) : TPointArray;

Returns the TPointArray TPA


CopyATPA
--------

.. code-block:: pascal

    function CopyATPA(const ATPA : T2DPointArray) : T2DPointArray;

Returns the T2DPointArray ATPA


PartitionTPA
------------

.. code-block:: pascal

    function PartitionTPA(const TPA: TPointArray; BoxWidth, BoxHeight: integer): T2DPointArray;

Partitions the TPA in boxes of BoxWidth and BoxHeight.

The following example will partition a TPA in boxes of 10 width, 10 height and debug it.

.. code-block:: pascal

  program PartitionTPA_Test;
   var
     tpa: TPointArray;
     atpa: T2DPointArray;
     canvas: integer;
  begin
    tpa := TPAFromEllipse(50, 50, 33, 45);
    FillEllipse(tpa);
    atpa := PartitionTPA(tpa, 10, 10);

    // debugging the result
    canvas := CreateBitmap(100, 100);
    DrawATPABitmap(canvas, atpa);
    ClearDebugImg();
    DisplayDebugImgWindow(100, 100);
    DrawBitmapDebugImg(canvas);
    FreeBitmap(canvas);
  end.  

