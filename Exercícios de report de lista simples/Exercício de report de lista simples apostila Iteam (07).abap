REPORT z_algj_31.

*--------------------------------------------------------------------*
* 7 - Elaborar um programa ABAP onde dever� ser criada uma tela de sele��o com
* o campo Fornecimento como sele��o m�ltipla e Itiner�rio como sele��o m�ltipla. Seus
* tipos se encontram na tabela LIKP.
*   Selecionar na tabela LIKP todos os Fornecimentos criados pelo usu�rio
* �MMUELLER� (Nome do respons�vel que adicionou o objeto), que sejam do Local de
* expedi��o/local de recebimento de mercadoria = �1200�, Organiza��o de vendas = �1000�
* e que tenham Itiner�rios definidos (Itiner�rio <> branco), onde o campo Fornecimento
* seja filtrado pelo campo Fornecimento da tela de sele��o e o campo Itiner�rio seja
* filtrado pelo campo Itiner�rio da tela de sele��o, retornando os campos Fornecimento,
* Data de cria��o do registro e Itiner�rio.
*   Para cada registro encontrado na tabela LIKP, selecionar os Itens de
* Fornecimento na tabela LIPS onde o campo Fornecimento relaciona as duas tabelas,
* retornando os campos Fornecimento, Item de remessa, N� do material, Centro,
* Quantidade fornecida de fato em UMV e Peso l�quido.
*   Para cada registro encontrado na tabela LIKP, selecionar na tabela TVROT as
* descri��es dos Itiner�rios selecionados desde que estas existam com C�digo de Idioma
* �PT�, onde o campo Itiner�rio relaciona as duas tabelas, retornando os campos: Itiner�rio
* e Denomina��o do Itiner�rio.
*   Para cada Itiner�rio (quebra) encontrado na tabela LIKP, o relat�rio deve exibir
* seus fornecimentos e itens de fornecimento. No final de cada itiner�rio dever� ser
* apresentada uma soma dos campos Quantidade fornecida de fato em UMV e Peso
* l�quido. Dever� tamb�m ser exibido um contador com a quantidade de registros
* encontrados.
*   Imprimir os campos: Itiner�rio, Denomina��o do Itiner�rio, Fornecimento, Data de
* cria��o do registro, Item de remessa, N� do material, Centro, Quantidade fornecida de
* fato em UMV e Peso l�quido.
*--------------------------------------------------------------------*

TYPES:

  BEGIN OF type_likp,
    vbeln TYPE likp-vbeln, "Fornecimento
    erdat TYPE likp-erdat, "Data de cria��o do registro
    route TYPE likp-route, "Itiner�rio
  END OF type_likp,

  BEGIN OF type_lips,
    vbeln TYPE lips-vbeln, "Fornecimento
    posnr TYPE lips-posnr, "Item de remessa
    matnr TYPE lips-matnr, "N� do material
    werks TYPE lips-werks, "Centro
    lfimg TYPE lips-lfimg, "Quantidade fornecida de fato, em UMV
    ntgew TYPE lips-ntgew, "Peso l�quido
  END OF type_lips,

  BEGIN OF type_tvrot,
    spras TYPE tvrot-spras, "C�digo de idioma
    route TYPE tvrot-route, "Itiner�rio
    bezei TYPE tvrot-bezei, "Denomina��o do itiner�rio
  END OF type_tvrot.

DATA:
  ti_likp  TYPE TABLE OF type_likp,
  ti_lips  TYPE TABLE OF type_lips,
  ti_tvrot TYPE TABLE OF type_tvrot.

DATA:
  wa_likp  TYPE type_likp,
  wa_lips  TYPE type_lips,
  wa_tvrot TYPE type_tvrot.

DATA:
  v_itinerario TYPE type_likp-route,
  v_cont_regi  TYPE i,
  v_tot_qua    TYPE type_lips-lfimg,
  v_tot_pes    TYPE type_lips-ntgew.


SELECT vbeln  "Fornecimento
       erdat  "Data de cria��o do registro
       route  "Itiner�rio
  FROM likp
  INTO TABLE ti_likp.

SELECT vbeln  "Fornecimento
       posnr  "Item de remessa
       matnr  "N� do material
       werks  "Centro
       lfimg  "Quantidade fornecida de fato, em UMV
       ntgew  "Peso l�quido
  FROM lips
  INTO TABLE ti_lips
   FOR ALL ENTRIES IN ti_likp
 WHERE vbeln = ti_likp-vbeln.

SELECT spras  "C�digo de idioma
       route  "Itiner�rio
       bezei  "Denomina��o do itiner�rio
  FROM tvrot
  INTO TABLE ti_tvrot
   FOR ALL ENTRIES IN ti_likp
 WHERE spras = 'PT'
   AND route = ti_likp-route.

SORT: ti_likp  BY vbeln
                  route,
      ti_lips  BY vbeln,
      ti_tvrot BY route.

LOOP AT ti_likp INTO wa_likp.

  CLEAR wa_lips.
  READ TABLE ti_lips INTO wa_lips WITH KEY
                                  vbeln = wa_likp-vbeln BINARY SEARCH.

  IF sy-subrc <> 0.
    CONTINUE.
  ENDIF.

  CLEAR wa_tvrot.
  READ TABLE ti_tvrot INTO wa_tvrot WITH KEY
                                    route = wa_likp-route BINARY SEARCH.

  IF sy-subrc <> 0.
    CONTINUE.
  ENDIF.

  IF v_itinerario <> wa_likp-route.

    IF v_itinerario IS NOT INITIAL.

  FORMAT RESET.
  FORMAT COLOR COL_TOTAL INTENSIFIED OFF.
  WRITE:
    /01 '|', 50 'TOTAL', 100 '|', v_tot_qua, 140 '|', v_tot_pes, 170 '|'.

  CLEAR: v_tot_qua,
         v_tot_pes.

    ENDIF.


    FORMAT RESET.
    FORMAT COLOR COL_KEY INTENSIFIED ON.
    WRITE:
      /01 '|', 'Itiner�rio',
       20 '|', 'Denomina��o do Itiner�rio',
      170 '|'.


    FORMAT RESET.
    FORMAT COLOR COL_HEADING INTENSIFIED OFF.
    WRITE:
      /01 '|', wa_likp-route,  "Itiner�rio
       20 '|', wa_tvrot-bezei, "Denomina��o do Itiner�rio
      170 '|'.

    v_itinerario = wa_likp-route.

    FORMAT RESET.
    FORMAT COLOR COL_KEY INTENSIFIED ON.
    WRITE:
      /01 '|', 'Fornecimento',
       20 '|', 'Data de cria��o do registro',
       50 '|', 'Item de remessa',
       70 '|', 'N� do material',
       90 '|', 'Centro',
      100 '|', 'Quantidade fornecida de fato em UMV',
      140 '|', 'Peso l�quido',
      170 '|'.

  ENDIF.


  FORMAT RESET.
  FORMAT COLOR COL_HEADING INTENSIFIED OFF.
  WRITE:
    /01 '|', wa_likp-route, "Fornecimento
     20 '|', wa_likp-erdat, "Data de cria��o do registro
     50 '|', wa_lips-posnr, "Item de remessa
     70 '|', wa_lips-matnr, "N� do material
     90 '|', wa_lips-werks, "Centro
    100 '|', wa_lips-lfimg, "Quantidade fornecida de fato em UMV
    140 '|', wa_lips-ntgew, "Peso l�quido
    170 '|'.

v_tot_qua = v_tot_qua + wa_lips-lfimg.
v_tot_pes = v_tot_pes + wa_lips-ntgew.

v_cont_regi = v_cont_regi + 1.

ENDLOOP.

  FORMAT RESET.
  FORMAT COLOR COL_TOTAL INTENSIFIED OFF.
  WRITE:
    /01 '|', 50 'QTDE DE REGISTROS', 100 '|', v_cont_regi, 170 '|'.
