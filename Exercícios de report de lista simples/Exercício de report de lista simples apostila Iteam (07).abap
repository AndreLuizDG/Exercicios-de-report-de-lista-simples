REPORT z_algj_31.

*--------------------------------------------------------------------*
* 7 - Elaborar um programa ABAP onde deverá ser criada uma tela de seleção com
* o campo Fornecimento como seleção múltipla e Itinerário como seleção múltipla. Seus
* tipos se encontram na tabela LIKP.
*   Selecionar na tabela LIKP todos os Fornecimentos criados pelo usuário
* ‘MMUELLER’ (Nome do responsável que adicionou o objeto), que sejam do Local de
* expedição/local de recebimento de mercadoria = ‘1200’, Organização de vendas = ‘1000’
* e que tenham Itinerários definidos (Itinerário <> branco), onde o campo Fornecimento
* seja filtrado pelo campo Fornecimento da tela de seleção e o campo Itinerário seja
* filtrado pelo campo Itinerário da tela de seleção, retornando os campos Fornecimento,
* Data de criação do registro e Itinerário.
*   Para cada registro encontrado na tabela LIKP, selecionar os Itens de
* Fornecimento na tabela LIPS onde o campo Fornecimento relaciona as duas tabelas,
* retornando os campos Fornecimento, Item de remessa, Nº do material, Centro,
* Quantidade fornecida de fato em UMV e Peso líquido.
*   Para cada registro encontrado na tabela LIKP, selecionar na tabela TVROT as
* descrições dos Itinerários selecionados desde que estas existam com Código de Idioma
* ‘PT’, onde o campo Itinerário relaciona as duas tabelas, retornando os campos: Itinerário
* e Denominação do Itinerário.
*   Para cada Itinerário (quebra) encontrado na tabela LIKP, o relatório deve exibir
* seus fornecimentos e itens de fornecimento. No final de cada itinerário deverá ser
* apresentada uma soma dos campos Quantidade fornecida de fato em UMV e Peso
* líquido. Deverá também ser exibido um contador com a quantidade de registros
* encontrados.
*   Imprimir os campos: Itinerário, Denominação do Itinerário, Fornecimento, Data de
* criação do registro, Item de remessa, Nº do material, Centro, Quantidade fornecida de
* fato em UMV e Peso líquido.
*--------------------------------------------------------------------*

TYPES:

  BEGIN OF type_likp,
    vbeln TYPE likp-vbeln, "Fornecimento
    erdat TYPE likp-erdat, "Data de criação do registro
    route TYPE likp-route, "Itinerário
  END OF type_likp,

  BEGIN OF type_lips,
    vbeln TYPE lips-vbeln, "Fornecimento
    posnr TYPE lips-posnr, "Item de remessa
    matnr TYPE lips-matnr, "Nº do material
    werks TYPE lips-werks, "Centro
    lfimg TYPE lips-lfimg, "Quantidade fornecida de fato, em UMV
    ntgew TYPE lips-ntgew, "Peso líquido
  END OF type_lips,

  BEGIN OF type_tvrot,
    spras TYPE tvrot-spras, "Código de idioma
    route TYPE tvrot-route, "Itinerário
    bezei TYPE tvrot-bezei, "Denominação do itinerário
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
       erdat  "Data de criação do registro
       route  "Itinerário
  FROM likp
  INTO TABLE ti_likp.

SELECT vbeln  "Fornecimento
       posnr  "Item de remessa
       matnr  "Nº do material
       werks  "Centro
       lfimg  "Quantidade fornecida de fato, em UMV
       ntgew  "Peso líquido
  FROM lips
  INTO TABLE ti_lips
   FOR ALL ENTRIES IN ti_likp
 WHERE vbeln = ti_likp-vbeln.

SELECT spras  "Código de idioma
       route  "Itinerário
       bezei  "Denominação do itinerário
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
      /01 '|', 'Itinerário',
       20 '|', 'Denominação do Itinerário',
      170 '|'.


    FORMAT RESET.
    FORMAT COLOR COL_HEADING INTENSIFIED OFF.
    WRITE:
      /01 '|', wa_likp-route,  "Itinerário
       20 '|', wa_tvrot-bezei, "Denominação do Itinerário
      170 '|'.

    v_itinerario = wa_likp-route.

    FORMAT RESET.
    FORMAT COLOR COL_KEY INTENSIFIED ON.
    WRITE:
      /01 '|', 'Fornecimento',
       20 '|', 'Data de criação do registro',
       50 '|', 'Item de remessa',
       70 '|', 'Nº do material',
       90 '|', 'Centro',
      100 '|', 'Quantidade fornecida de fato em UMV',
      140 '|', 'Peso líquido',
      170 '|'.

  ENDIF.


  FORMAT RESET.
  FORMAT COLOR COL_HEADING INTENSIFIED OFF.
  WRITE:
    /01 '|', wa_likp-route, "Fornecimento
     20 '|', wa_likp-erdat, "Data de criação do registro
     50 '|', wa_lips-posnr, "Item de remessa
     70 '|', wa_lips-matnr, "Nº do material
     90 '|', wa_lips-werks, "Centro
    100 '|', wa_lips-lfimg, "Quantidade fornecida de fato em UMV
    140 '|', wa_lips-ntgew, "Peso líquido
    170 '|'.

v_tot_qua = v_tot_qua + wa_lips-lfimg.
v_tot_pes = v_tot_pes + wa_lips-ntgew.

v_cont_regi = v_cont_regi + 1.

ENDLOOP.

  FORMAT RESET.
  FORMAT COLOR COL_TOTAL INTENSIFIED OFF.
  WRITE:
    /01 '|', 50 'QTDE DE REGISTROS', 100 '|', v_cont_regi, 170 '|'.
