create or replace PROCEDURE add_product (p_productname IN VARCHAR2,
                                         p_price IN NUMBER,
                                         p_quantity IN NUMBER,
                                         p_commit IN BOOLEAN DEFAULT FALSE) IS
                                         
    v_productid NUMBER;

    FUNCTION get_max_productid RETURN NUMBER IS

        v_productid NUMBER;

    BEGIN

        SELECT NVL(MAX(productid),0)+1
        INTO v_productid
        FROM products;
        RETURN v_productid;

    END get_max_productid;

BEGIN

    v_productid := get_max_productid;

    INSERT INTO products (productid,productname,price,quantity)
    VALUES (v_productid,p_productname,p_price,p_quantity);

    IF p_commit = TRUE THEN
        COMMIT;
    END IF;

    dbms_output.put_line('Продукт '||p_productname||' успішно доданий до таблиці Products.');

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Виникла помилка: '||sqlerrm);

END add_product;

create or replace PROCEDURE add_test_curr IS

BEGIN

    INSERT INTO cur_exchange (r030, txt, rate, cur, exchangedate)
    SELECT ROUND(dbms_random.value(100, 1000)) AS r030,
        'Тестова валюта №'||ROUND(dbms_random.value(1, 100)) AS txt,
        ROUND(dbms_random.value(20, 50), 4) AS rate,
        dbms_random.string('X',3) AS cur,
        TRUNC(SYSDATE, 'DD') AS exchangedate
    FROM dual;

    COMMIT;

END add_test_curr;

create or replace PROCEDURE download_ibank_index_ua IS

BEGIN

    INSERT INTO interbank_index_ua_history (index_date, api, index_value, special)
    SELECT index_date, 
           api, 
           index_value, 
           special
    FROM interbank_index_ua_v;

    COMMIT;

END download_ibank_index_ua;

create or replace PROCEDURE to_log(p_appl_proc IN VARCHAR2,
                        p_message   IN VARCHAR2) IS
                        
        PRAGMA autonomous_transaction;

BEGIN

    INSERT INTO logs(id, appl_proc, message)
    VALUES(log_seq.NEXTVAL, p_appl_proc, p_message);
    COMMIT;

END to_log;

create or replace PROCEDURE write_file_to_disk IS
    file_handle UTL_FILE.FILE_TYPE;
    file_location VARCHAR2(200) := 'FILES_FROM_SERVER'; -- Назва створеної директорії
    file_name VARCHAR2(200) := 'file_sdu.csv'; -- Ім'я файлу, який буде записаний
    file_content VARCHAR2(4000); -- Вміст файл

BEGIN

    FOR cc IN (SELECT job_id ||','|| job_title ||','|| min_salary ||','|| max_salary AS file_content
               FROM jobs) LOOP
            file_content := file_content || cc.file_content || CHR(10);
    END LOOP;

    file_handle := utl_file.fopen(file_location,file_name,'W');

    utl_file.put_raw(file_handle, utl_raw.cast_to_raw(file_content));

    utl_file.fclose(file_handle);

EXCEPTION
    WHEN OTHERS THEN
        RAISE;

END write_file_to_disk;
