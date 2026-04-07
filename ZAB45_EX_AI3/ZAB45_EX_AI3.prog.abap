*----------------------------------------------------------------------*
* CLASS lcl_employee_helper DEFINITION
*----------------------------------------------------------------------*

REPORT zab45_ex_ai3.

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
        not_found.                     " 定義找不到資料時的例外
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
ENDCLASS.

*----------------------------------------------------------------------*
* 主程式執行區塊 (Main Program)
*----------------------------------------------------------------------*
START-OF-SELECTION.
  DATA: lo_helper TYPE REF TO lcl_employee_helper,
        lv_depid  TYPE zab45_emp-depid,
        lv_class  TYPE zab45_emp-class.

  " 建立類別物件 (ABAP 7.40+ 亦可用 lo_helper = NEW lcl_employee_helper( ) )
  CREATE OBJECT lo_helper.

  " 呼叫獲取員工資訊的方法
  lo_helper->get_emp_info(
    EXPORTING
      im_emoid  = '10000'      " 請替換成實際要查詢的員工編號
    IMPORTING
      ex_depid  = lv_depid
      ex_class  = lv_class
    EXCEPTIONS
      not_found = 1            " 捕捉例外並設定 sy-subrc
      OTHERS    = 2
  ).

  " 判斷執行結果並顯示對應訊息
  IF sy-subrc = 1.
    WRITE: / '查無此員工'.
  ELSEIF sy-subrc = 0.
    WRITE: / '查詢成功！'.
    WRITE: / '部門編號：', lv_depid.
    WRITE: / '職等：', lv_class.
  ENDIF.