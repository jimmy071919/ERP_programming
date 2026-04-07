*&---------------------------------------------------------------------*
*& Report ZAB45_EX_AI4_PLUS
*&---------------------------------------------------------------------*
REPORT zab45_ex_ai4_plus.

* 1. 宣告完整型別 (Fully Typed) 的內部表格，供 RETURNING 參數使用
TYPES: tt_emps TYPE STANDARD TABLE OF zab45_emp WITH DEFAULT KEY.

" 【新增】用來存放「每個部門薪資總和」的結構與內部表格型別
TYPES: BEGIN OF ty_dept_wage,
         depid      TYPE zab45_emp-depid,
         total_wage TYPE p DECIMALS 2, " 使用 Packed number 確保有足夠長度存放總和
       END OF ty_dept_wage.
TYPES: tt_dept_wages TYPE STANDARD TABLE OF ty_dept_wage WITH DEFAULT KEY.

*----------------------------------------------------------------------*
* CLASS lcl_employee_helper DEFINITION
*----------------------------------------------------------------------*

CLASS lcl_employee_helper DEFINITION.
  PUBLIC SECTION.
    " 定義公開方法
    METHODS: get_emp_info
      IMPORTING
        im_emoid TYPE zab45_emp-emoid  " 假設員工編號欄位名稱為 EMPID
      EXPORTING
        ex_depid TYPE zab45_emp-depid
        ex_class TYPE zab45_emp-class
      EXCEPTIONS
        not_found.

    METHODS get_dept_employees
      IMPORTING
        im_depid       TYPE zab45_emp-depid  " 請替換成 zabtc_emp 實際的部門代號欄位名稱
      RETURNING
        VALUE(rt_emps) TYPE tt_emps.

    " 【新增】統計每個部門的總薪水的方法
    METHODS get_all_dept_wages
      RETURNING
        VALUE(rt_dept_wages) TYPE tt_dept_wages.

ENDCLASS.

*----------------------------------------------------------------------*
* CLASS lcl_employee_helper IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_employee_helper IMPLEMENTATION.
  METHOD get_emp_info.
    " 使用 Open SQL 查詢員工的部門與職等
    SELECT SINGLE depid class
      FROM zab45_emp
      INTO (ex_depid, ex_class)
      WHERE emoid = im_emoid.

    " 判斷是否查詢到資料，若無則觸發例外
    IF sy-subrc <> 0.
      RAISE not_found.
    ENDIF.
  ENDMETHOD.

  METHOD get_dept_employees.
    " 將該部門所有的員工資料撈取出來，存入 rt_emps
    SELECT *
      FROM zab45_emp
      WHERE depid = @im_depid
      INTO TABLE @rt_emps.
  ENDMETHOD.

  METHOD get_all_dept_wages.
    " 【新增】把員工表(emp)與薪資表(wag) JOIN 起來
    " 並利用 GROUP BY 與 SUM()...AS 計算各部門總薪資
    SELECT e~depid, SUM( w~wage ) AS total_wage
      FROM zab45_emp AS e
      INNER JOIN zab45_wag AS w ON e~class = w~class
      GROUP BY e~depid
      INTO TABLE @rt_dept_wages.
  ENDMETHOD.

ENDCLASS.

*----------------------------------------------------------------------*
* 主程式執行區塊 (Main Program)
*----------------------------------------------------------------------*
START-OF-SELECTION.
  DATA: lo_helper TYPE REF TO lcl_employee_helper,
        lv_depid  TYPE zab45_emp-depid,
        lv_class  TYPE zab45_emp-class,
        lt_emps   TYPE tt_emps,
        ls_emp    TYPE zab45_emp.

  " 【新增】宣告接收總薪資的變數
  DATA: lt_dept_wages TYPE tt_dept_wages,
        ls_dept_wage  TYPE ty_dept_wage.

  " 建立類別物件
  CREATE OBJECT lo_helper.

  " 1. 呼叫獲取員工資訊的方法
  lo_helper->get_emp_info(
    EXPORTING
      im_emoid  = '10000'
    IMPORTING
      ex_depid  = lv_depid
      ex_class  = lv_class
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2
  ).

  " 判斷執行結果並顯示對應訊息
  IF sy-subrc = 1.
    WRITE: / '查無此員工'.
  ELSEIF sy-subrc = 0.
    WRITE: / '員工單筆查詢成功！'.
    WRITE: / '部門編號：', lv_depid.
    WRITE: / '職等：', lv_class.
  ENDIF.

  SKIP 2. " 畫面上空兩行

  " 2. 獲取特定部門(ACC01)所有員工
  lt_emps = lo_helper->get_dept_employees( im_depid = 'ACC01' ).

  WRITE: / '部門 ACC01 員工名單:'.
  ULINE.
  IF lt_emps IS NOT INITIAL.
    LOOP AT lt_emps INTO ls_emp.
      WRITE: / '部門:', ls_emp-depid,
              ' | 員工編號:', ls_emp-emoid,
              ' | 員工姓名:', ls_emp-name.
    ENDLOOP.
  ELSE.
    WRITE: / '查無此部門的員工資料'.
  ENDIF.

  SKIP 2.

  " 3. 【新增】呼叫統計各部門總薪水的方法並印出
  lt_dept_wages = lo_helper->get_all_dept_wages( ).

  WRITE: / '各部門總薪水統計:'.
  ULINE.
  IF lt_dept_wages IS NOT INITIAL.
    LOOP AT lt_dept_wages INTO ls_dept_wage.
      WRITE: / '部門：', ls_dept_wage-depid,
               ' | 總薪資：', ls_dept_wage-total_wage.
    ENDLOOP.
  ELSE.
    WRITE: / '查無部門薪資資料'.
  ENDIF.