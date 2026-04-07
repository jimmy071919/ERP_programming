*&---------------------------------------------------------------------*
*& Report  ZAB45_HW01
*&---------------------------------------------------------------------*
*& AB45 HOMEWORK 1
*&---------------------------------------------------------------------*
REPORT zab45_hw01.

*----------------------------------------------------------------------*
* 全域資料宣告 (Data Declarations)
*----------------------------------------------------------------------*
" 宣告存放查詢結果的結構 (依據您 ZAB45 系列的實際欄位型別為準)
TYPES: BEGIN OF ty_emp,
         emoid TYPE zab45_emp-emoid, " 假設員工編號欄位是 emoid 或 empid
         name  TYPE zab45_emp-name,  " 假設員工姓名欄位是 name
         depid TYPE zab45_emp-depid,
         class TYPE zab45_emp-class,  " 假設職位欄位是 class (稍早您有使用過 class)
       END OF ty_emp.

TYPES: BEGIN OF ty_dep,
         depid   TYPE zab45_dep-depid,
         depname TYPE zab45_dep-depname,
       END OF ty_dep.

TYPES: BEGIN OF ty_wag,
         class TYPE zab45_wag-class,
         wage  TYPE zab45_wag-wage,
       END OF ty_wag.

" 宣告最終要印出畫面的統一結構
TYPES: BEGIN OF ty_final,
         empname TYPE zab45_emp-name,
         depname TYPE zab45_dep-depname,
         class   TYPE zab45_wag-class,
         wage    TYPE zab45_wag-wage,
       END OF ty_final.

" 內部表格(Internal Tables)與工作區(Work Areas)
DATA: lt_emp TYPE TABLE OF ty_emp,
      lt_dep TYPE TABLE OF ty_dep,
      lt_wag TYPE TABLE OF ty_wag,
      ls_emp TYPE ty_emp,
      ls_dep TYPE ty_dep,
      ls_wag TYPE ty_wag.

" Method 2 專用
DATA: lt_final TYPE TABLE OF ty_final,
      ls_final TYPE ty_final.


START-OF-SELECTION.
*======================================================================*
* Method 1. 限制 SELECT ... FROM 中的 TABLE 數目只能有一個
* 技法：利用 FOR ALL ENTRIES 搭配 READ TABLE (效能優於巢狀 SELECT)
*======================================================================*
  WRITE: / '========== Method 1: FOR ALL ENTRIES =========='.
  ULINE.

  " 1. 從員工表抓取所有員工資料
  SELECT emoid, name, depid, class
    FROM zab45_emp
    INTO TABLE @lt_emp.

  IF sy-subrc = 0 AND lt_emp IS NOT INITIAL.
    " 2. 針對員工資料內出現的部門，去部門表抓名稱
    SELECT depid, depname
      FROM zab45_dep
      INTO TABLE @lt_dep
      FOR ALL ENTRIES IN @lt_emp
      WHERE depid = @lt_emp-depid.

    " 3. 針對員工資料內出現的職位，去薪資表抓薪資
    SELECT class, wage
      FROM zab45_wag
      INTO TABLE @lt_wag
      FOR ALL ENTRIES IN @lt_emp
      WHERE class = @lt_emp-class.

    " 為了讓接下來的 READ TABLE 效能極佳，先根據 Key 值進行排序
    SORT lt_dep BY depid.
    SORT lt_wag BY class.

    " 4. 使用迴圈逐筆巡覽員工，並去讀取對應的部門與薪資
    LOOP AT lt_emp INTO ls_emp.
      " 先清空工作區，避免殘留上一筆資料
      CLEAR: ls_dep, ls_wag.

      " 利用 BINARY SEARCH (二元搜尋) 快速讀取另外兩張內部表的紀錄
      READ TABLE lt_dep INTO ls_dep WITH KEY depid = ls_emp-depid BINARY SEARCH.
      READ TABLE lt_wag INTO ls_wag WITH KEY class  = ls_emp-class  BINARY SEARCH.

      " 印出結果 (只印出題目要求的四個欄位)
      WRITE: / '部門名稱:', ls_dep-depname,
               '| 員工姓名:', ls_emp-name,
               '| 職位(class):', ls_emp-class,
               '| 薪資(WAGE):', ls_wag-wage.
    ENDLOOP.

  ELSE.
    WRITE: / '查無任何員工資料'.
  ENDIF.

  SKIP 2. " 空兩行分隔

*======================================================================*
* Method 2. 不限制 SELECT ... FROM 中的 TABLE 數目
* 技法：使用 INNER JOIN
*======================================================================*
  WRITE: / '========== Method 2: INNER JOIN =========='.
  ULINE.

  " 清空剛剛宣告過的變數，保持乾淨
  CLEAR: lt_final, ls_final.

  " 直接在資料庫層執行三表關聯 (Table Join)
  SELECT d~depname,
         e~name AS empname,
         e~class,
         w~wage
    FROM zab45_emp AS e
    INNER JOIN zab45_dep AS d ON e~depid = d~depid
    INNER JOIN zab45_wag AS w ON e~class  = w~class
    INTO TABLE @lt_final.

  IF sy-subrc = 0.
    " 成功查到資料，直接 LOOP 輸出
    LOOP AT lt_final INTO ls_final.
      WRITE: / '部門名稱:', ls_final-depname,
               '| 員工姓名:', ls_final-empname,
               '| 職位(class):', ls_final-class,
               '| 薪資(WAGE):', ls_final-wage.
    ENDLOOP.
  ELSE.
    WRITE: / '查無任何關連資料'.
  ENDIF.