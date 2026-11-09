*&---------------------------------------------------------------------*
*& Report ZMM_PROCUREMENT_ALV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_procurement_alv NO STANDARD PAGE HEADING.

* Project: SAP Procurement Intelligence
* Purpose: Procurement ALV Reporting

*PARAMETERS: p_ebeln TYPE ebeln.

DATA: gv_ebeln TYPE ekko-ebeln,
      gv_bukrs TYPE ekko-bukrs,
      gv_lifnr TYPE ekko-lifnr.

SELECT-OPTIONS: s_ebeln FOR gv_ebeln,
                s_bukrs FOR gv_bukrs,
                s_lifnr FOR gv_lifnr.

TYPES: BEGIN OF ty_purchase_order,
         "ekko
         ebeln TYPE ekko-ebeln, "Purchasing Document Number
         bukrs TYPE ekko-bukrs, "Company Code
         lifnr TYPE ekko-lifnr, "Supplier's Account Number
         "ekpo
         ebelp TYPE ekpo-ebelp, "Item Number of Purchasing Document - Primary Key
         matnr TYPE ekpo-matnr, "Material Number
         werks TYPE ekpo-werks, "Plant
         menge TYPE ekpo-menge, "Purchase Order Quantity
         netpr TYPE ekpo-netpr, "Net Price
         netwr TYPE ekpo-netwr, "Net Order Value
       END OF ty_purchase_order.


TYPE-POOLS: slis. "ALV


DATA: gt_report TYPE TABLE OF ty_purchase_order,
      gs_report TYPE ty_purchase_order,
      gv_count  TYPE i.


DATA: gt_fieldcat TYPE slis_t_fieldcat_alv, "ALV
      gs_fieldcat TYPE slis_fieldcat_alv.


START-OF-SELECTION. "This is where our report's main logic will execute.

  PERFORM get_data.
  PERFORM print_fieldcat.

END-OF-SELECTION.
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*

FORM get_data .

  "Old abap syntax
**  SELECT a~ebeln a~bukrs a~lifnr
**    b~ebelp b~matnr b~werks b~menge b~netpr b~netwr
**    FROM ekko as a inner join ekpo as b
**    on a~ebeln = b~ebeln
**    into CORRESPONDING FIELDS OF table gt_report
**    where a~ebeln = p_ebeln.

  "New abap syntax
  SELECT a~ebeln, a~bukrs, a~lifnr,
     b~ebelp, b~matnr, b~werks, b~menge, b~netpr, b~netwr
    FROM ekko AS a INNER JOIN ekpo AS b
    ON a~ebeln = b~ebeln
    INTO CORRESPONDING FIELDS OF TABLE @gt_report
    WHERE a~ebeln IN @s_ebeln
      AND a~bukrs IN @s_bukrs
      AND a~lifnr IN @s_lifnr.

  gv_count = lines( gt_report ).

  WRITE:/2 'Purchase Order Selection Applied'.
  WRITE:/2 'Items Retrieved', 22 ': ' , 25 gv_count.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form PRINT_FIELDCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM print_fieldcat .

  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname = 'EBELN'.
  gs_fieldcat-seltext_m = 'PO NUMBER'. "SELECTION TEXT
  gs_fieldcat-tabname = 'GT_REPORT'. "TABLE NAME
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname = 'BUKRS'.
  gs_fieldcat-seltext_m = 'COMPANY CODE'.
  gs_fieldcat-tabname = 'GT_REPORT'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname = 'LIFNR'.
  gs_fieldcat-seltext_m = 'Supplier'.
  gs_fieldcat-tabname = 'GT_REPORT'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname = 'EBELP'.
  gs_fieldcat-seltext_m = 'Item Number'.
  gs_fieldcat-tabname = 'GT_REPORT'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname = 'MATNR'.
  gs_fieldcat-seltext_m = 'MATERIAL NUMBER'.
  gs_fieldcat-tabname = 'GT_REPORT'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname = 'WERKS'.
  gs_fieldcat-seltext_m = 'PLANT'.
  gs_fieldcat-tabname = 'GT_REPORT'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname = 'MENGE'.
  gs_fieldcat-seltext_m = 'PO QUANTITY'.
  gs_fieldcat-tabname = 'GT_REPORT'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname = 'NETPR'.
  gs_fieldcat-seltext_m = 'NET PRICE'.
  gs_fieldcat-tabname = 'GT_REPORT'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname = 'NETWR'.
  gs_fieldcat-seltext_m = 'NET ORDER VALUE'.
  gs_fieldcat-tabname = 'GT_REPORT'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.

  IF gt_report IS INITIAL.

    WRITE: 'No purchasing items found for the selection.' COLOR 6 INVERSE ON.

  ELSE.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        it_fieldcat        = gt_fieldcat
        i_callback_program = sy-repid
      TABLES
        t_outtab           = gt_report.

  ENDIF.

ENDFORM.