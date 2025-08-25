@echo off

setlocal enabledelayedexpansion

mode con: cols=40 lines=15

:MAIN_MENU
cls
echo ========================================
echo               LIST CREATOR
echo ========================================
echo.
echo   1. Create New List
echo   2. View Existing List
echo   3. Delete List
echo   4. Exit
echo.
set /p choice="   Enter your choice (1-4): "

if "%choice%"=="1" goto CREATE_LIST
if "%choice%"=="2" goto VIEW_LIST
if "%choice%"=="3" goto DELETE_LIST
if "%choice%"=="4" exit /b
echo    Invalid choice! Please try again.
timeout /t 2 >nul
goto MAIN_MENU

:CREATE_LIST
cls
echo ========================================
echo            CREATE NEW LIST
echo ========================================
echo.
set /p list_name="   Enter list file name: "
if "!list_name!"=="" (
    echo    List name cannot be empty!
    timeout /t 2 >nul
    goto MAIN_MENU
)

set "list_file=!list_name!.txt"
if exist "!list_file!" (
    echo    List "!list_name!" already exists!
    echo    1. Overwrite existing list
    echo    2. Choose different name
    echo    3. Return to main menu
    set /p overwrite="   Enter choice: "
    if "!overwrite!"=="1" (
        del "!list_file!"
    ) else if "!overwrite!"=="2" (
        goto CREATE_LIST
    ) else (
        goto MAIN_MENU
    )
)

:ADD_ITEMS
cls
echo ========================================
echo        ADDING ITEMS TO: !list_name!
echo ========================================
echo.
echo    Current items in list:
if exist "!list_file!" (
    call :SHOW_LIST_ITEMS "!list_file!"
) else (
    echo    No items yet.
)
echo.
echo   1. Add new item
echo   2. Finish and save list
echo   3. Cancel (discard list)
echo.
set /p item_choice="   Enter choice: "

if "!item_choice!"=="1" goto ADD_ITEM
if "!item_choice!"=="2" goto SAVE_LIST
if "!item_choice!"=="3" (
    if exist "!list_file!" del "!list_file!"
    goto MAIN_MENU
)
goto ADD_ITEMS

:ADD_ITEM
cls
echo ========================================
echo              ADD NEW ITEM
echo ========================================
echo.
set /p item_number="   Enter item number: "
if "!item_number!"=="" (
    echo    Item number cannot be empty!
    timeout /t 2 >nul
    goto ADD_ITEM
)

set /p item_text="   Enter item text: "
if "!item_text!"=="" (
    echo    Item text cannot be empty!
    timeout /t 2 >nul
    goto ADD_ITEM
)

set /p item_status="   Enter item status: "
if "!item_status!"=="" (
    echo    Item status cannot be empty!
    timeout /t 2 >nul
    goto ADD_ITEM
)

echo !item_number! >> "!list_file!"
echo !item_text! >> "!list_file!"
echo !item_status! >> "!list_file!"
echo. >> "!list_file!"
echo    Item added successfully!
timeout /t 2 >nul
goto ADD_ITEMS

:SAVE_LIST
echo    List "!list_name!" saved successfully!
timeout /t 2 >nul
goto MAIN_MENU

:VIEW_LIST
cls
echo ========================================
echo               VIEW LISTS
echo ========================================
echo.
echo   Available lists:
set count=0
for %%f in (*.txt) do (
    set /a count+=1
    echo   !count!. %%~nf
)

if !count! equ 0 (
    echo   No lists found!
    timeout /t 2 >nul
    goto MAIN_MENU
)

echo.
set /p list_choice="   Enter list number to view (or 'b' to go back): "
if /i "!list_choice!"=="b" goto MAIN_MENU

set count=0
set selected_list=
for %%f in (*.txt) do (
    set /a count+=1
    if !count! equ !list_choice! (
        set selected_list=%%~nf
    )
)

if "!selected_list!"=="" (
    echo   Invalid selection!
    timeout /t 2 >nul
    goto VIEW_LIST
)

set "view_file=!selected_list!.txt"
goto VIEW_LIST_DETAILS

:VIEW_LIST_DETAILS
cls
echo ========================================
echo        VIEWING LIST: !selected_list!
echo ========================================
echo.
if not exist "!view_file!" (
    echo   List file not found!
    timeout /t 2 >nul
    goto VIEW_LIST
)

call :SHOW_LIST_ITEMS "!view_file!"

echo.
:VIEW_LIST_OPTIONS
echo   1. Edit item
echo   2. Delete item
echo   3. Add new item
echo   4. Back to list selection
echo   5. Main menu
echo.
set /p view_choice="   Enter choice: "

if "!view_choice!"=="1" goto EDIT_ITEM
if "!view_choice!"=="2" goto DELETE_ITEM
if "!view_choice!"=="3" goto ADD_TO_EXISTING
if "!view_choice!"=="4" goto VIEW_LIST
if "!view_choice!"=="5" goto MAIN_MENU
goto VIEW_LIST_OPTIONS

:EDIT_ITEM
set /p edit_number="   Enter item number to edit: "
if "!edit_number!"=="" goto EDIT_ITEM

set temp_file=temp_edit.txt
if exist "!temp_file!" del "!temp_file!"

set current_item=0
set found=0
set line_num=0
set skip_next=0

for /f "usebackq delims=" %%a in ("!view_file!") do (
    set /a line_num+=1
    set /a mod=!line_num! %% 4
    
    if !mod! equ 1 (
        set /a current_item+=1
        if !current_item! equ !edit_number! (
            set found=1
            cls
            echo ========================================
            echo          EDITING ITEM !current_item!
            echo ========================================
            echo.
            echo   Current values:
            echo   Number: %%a
            for /f "usebackq skip=!line_num! delims=" %%b in ("!view_file!") do (
                echo   Text: %%b
                goto :get_text
            )
            :get_text
            for /f "usebackq skip=!line_num!+1 delims=" %%c in ("!view_file!") do (
                echo   Status: %%c
                goto :get_status
            )
            :get_status
            echo.
            set /p new_number="   Enter new number [%%a]: "
            if "!new_number!"=="" set new_number=%%a
            
            for /f "usebackq skip=!line_num! delims=" %%b in ("!view_file!") do (
                set current_text=%%b
                goto :edit_text
            )
            :edit_text
            set /p new_text="   Enter new text [!current_text!]: "
            if "!new_text!"=="" set new_text=!current_text!
            
            for /f "usebackq skip=!line_num!+1 delims=" %%c in ("!view_file!") do (
                set current_status=%%c
                goto :edit_status
            )
            :edit_status
            set /p new_status="   Enter new status [!current_status!]: "
            if "!new_status!"=="" set new_status=!current_status!
            
            echo !new_number! >> "!temp_file!"
            echo !new_text! >> "!temp_file!"
            echo !new_status! >> "!temp_file!"
            echo. >> "!temp_file!"
            set skip_next=3
        ) else (
            echo %%a >> "!temp_file!"
        )
    ) else if !skip_next! gtr 0 (
        set /a skip_next-=1
    ) else (
        echo %%a >> "!temp_file!"
    )
)

if exist "!temp_file!" (
    move /y "!temp_file!" "!view_file!" >nul
    echo   Item updated successfully!
) else (
    echo   Item not found!
)
timeout /t 2 >nul
goto VIEW_LIST_DETAILS

:DELETE_ITEM
set /p delete_number="   Enter item number to delete: "
if "!delete_number!"=="" goto DELETE_ITEM

set temp_file=temp_delete.txt
if exist "!temp_file!" del "!temp_file!"

set current_item=0
set found=0
set line_num=0
set skip_next=0

for /f "usebackq delims=" %%a in ("!view_file!") do (
    set /a line_num+=1
    set /a mod=!line_num! %% 4
    
    if !mod! equ 1 (
        set /a current_item+=1
        if !current_item! equ !delete_number! (
            set found=1
            set skip_next=3
        ) else (
            echo %%a >> "!temp_file!"
        )
    ) else if !skip_next! gtr 0 (
        set /a skip_next-=1
    ) else (
        echo %%a >> "!temp_file!"
    )
)

if exist "!temp_file!" (
    move /y "!temp_file!" "!view_file!" >nul
    echo   Item deleted successfully!
) else (
    echo   Item not found or list is now empty!
)
timeout /t 2 >nul
goto VIEW_LIST_DETAILS

:ADD_TO_EXISTING
cls
echo ========================================
echo            ADD ITEM TO LIST
echo ========================================
echo.
set /p new_number="   Enter new item number: "
if "!new_number!"=="" goto ADD_TO_EXISTING

set /p new_text="   Enter new item text: "
if "!new_text!"=="" goto ADD_TO_EXISTING

set /p new_status="   Enter new item status: "
if "!new_status!"=="" goto ADD_TO_EXISTING

echo !new_number! >> "!view_file!"
echo !new_text! >> "!view_file!"
echo !new_status! >> "!view_file!"
echo. >> "!view_file!"
echo   New item added successfully!
timeout /t 2 >nul
goto VIEW_LIST_DETAILS

:DELETE_LIST
cls
echo ========================================
echo               DELETE LIST
echo ========================================
echo.
echo   Available lists:
set count=0
for %%f in (*.txt) do (
    set /a count+=1
    echo   !count!. %%~nf
)

if !count! equ 0 (
    echo   No lists found!
    timeout /t 2 >nul
    goto MAIN_MENU
)

echo.
set /p delete_choice="   Enter list number to delete (or 'b' to go back): "
if /i "!delete_choice!"=="b" goto MAIN_MENU

set count=0
set delete_list=
for %%f in (*.txt) do (
    set /a count+=1
    if !count! equ !delete_choice! (
        set delete_list=%%~nf
    )
)

if "!delete_list!"=="" (
    echo   Invalid selection!
    timeout /t 2 >nul
    goto DELETE_LIST
)

set "delete_file=!delete_list!.txt"
echo.
echo   WARNING: This will delete the list "!delete_list!"
set /p confirm="   Are you sure? (y/N): "
if /i "!confirm!"=="y" (
    del "!delete_file!"
    echo   List "!delete_list!" deleted successfully!
) else (
    echo   Deletion cancelled.
)
timeout /t 2 >nul
goto MAIN_MENU

:SHOW_LIST_ITEMS
setlocal
set "file=%~1"
set item_count=0
set line_num=0

for /f "usebackq delims=" %%a in ("!file!") do (
    set /a line_num+=1
    set /a mod=!line_num! %% 4
    if !mod! equ 1 (
        set /a item_count+=1
        echo   [!item_count!] Number: %%a
    ) else if !mod! equ 2 (
        echo        Text: %%a
    ) else if !mod! equ 3 (
        echo        Status: %%a
        echo.
    )
)

if !item_count! equ 0 (
    echo   List is empty.
)
endlocal
goto :eof