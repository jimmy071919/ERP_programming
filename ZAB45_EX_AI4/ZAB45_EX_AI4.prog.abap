*&---------------------------------------------------------------------*
*& Report ZAB45_EX_AI4
*&---------------------------------------------------------------------*
REPORT zab45_ex_ai4.

* 1. 宣告完整型別 (Fully Typed) 的內部表格，供 RETURNING 參數使用
TYPES: tt_emps TYPE STANDARD TABLE OF zab45_emp WITH DEFAULT KEY.

*----------------------------------------------------------------------*
* CLASS lcl_department DEFINITION (類別定義)
*----------------------------------------------------------------------*
CLASS lcl_department DEFINITION.
  PUBLIC SECTION.
    " 宣告方法，接收部門代號並回傳內部表格
    METHODS get_dept_employees
      IMPORTING
        im_depid       TYPE zab45_emp-depid  " 請替換成 zabtc_emp 實際的部門代號欄位名稱
      RETURNING
        VALUE(rt_emps) TYPE tt_emps.
ENDCLASS.

*----------------------------------------------------------------------*
* CLASS lcl_department IMPLEMENTATION (類別實作)
*----------------------------------------------------------------------*
CLASS lcl_department IMPLEMENTATION.

  METHOD get_dept_employees.
    " 將該部門所有的員工資料從 zabtc_emp 撈取出來，存入 rt_emps
    SELECT *
      FROM zab45_emp
      WHERE depid = @im_depid   " 這裡的 depid 請確認是否為資料表實際欄位名稱
      INTO TABLE @rt_emps.
  ENDMETHOD.

ENDCLASS.

*----------------------------------------------------------------------*
* MAIN PROGRAM (主程式)
*----------------------------------------------------------------------*
" 宣告物件參考與變數
DATA: lo_dept TYPE REF TO lcl_department,
      lt_emps TYPE tt_emps,
      ls_emp  TYPE zab45_emp.

START-OF-SELECTION.

  " 1. 實體化這個物件
  CREATE OBJECT lo_dept.
  " (若您的系統支援 ABAP 7.40+ 語法，也可寫成 DATA(lo_dept) = NEW lcl_department( ). )

  " 2. 呼叫該方法 (假設我們要查詢的部門代號為 'D01')
  lt_emps = lo_dept->get_dept_employees( im_depid = 'ACC01' ).

  " 3. 用 LOOP AT 將回傳的表格內容依序印出
  WRITE: / '部門員工名單:'.
  ULINE.

  IF lt_emps IS NOT INITIAL.
    LOOP AT lt_emps INTO ls_emp.
      " 這裡印出的欄位 (例如 emp_id, emp_name) 請依據 zabtc_emp 的實際欄位做修改
      WRITE: / '部門:', ls_emp-depid,
               ' | 員工編號:', ls_emp-depid,    " 假設欄位名為 empid
               ' | 員工姓名:', ls_emp-name.  " 假設欄位名為 empname
    ENDLOOP.
  ELSE.
    WRITE: / '查無此部門的員工資料'.
  ENDIF.