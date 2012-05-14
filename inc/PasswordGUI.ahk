	string := "124934412"
	password := "007"
	hash := Crypt.Encrypt.StrEncrypt(string,password,5,1) ; encrypts string using AES_128 encryption and MD5 hash
	clipboard := hash
	decrypted_string := Crypt.Encrypt.StrDecrypt(hash,password,5,1)				  ; decrypts the string using previously generated hash,AES_128 and MD5
GUI11()
{
	GUI 11:destroy
	if password_remark =
		password_remark = In order to save a password, you need to log in.`nThis login will be used to encrypt and decrypt the passwords.`n`nNote: Pressing Cancel empties the login details.
	GUI 11:ADD, Text, xs y+2 vgui11_text_01 w300 r6 section, `n%password_remark%
	GUI 11:ADD, Text, xs w50 section, User
	GUI 11:ADD, Edit, ys-2 w250 vlogin_user,
	GUI 11:ADD, Text, xs w50 section, Password
	GUI 11:ADD, Edit, ys-2 w250 vlogin_password password,
	GUI 11:ADD, Button, x125 gsub_gui11_quit vgui11_cancel w50 section, Cancel
	GUI 11:ADD, Button, ys default gsub_gui11_ok vgui11_ok w50, OK
	GUI 11:show, xcenter ycenter, %app_name% : Password
	password_remark :=
}
sub_gui11_ok:
	GUI 11:submit, nohide
	user_key = %login_user%%login_password%
	if adding = 1	; only write the line if we're adding, else, just log in.
	{
		hash := Crypt.Encrypt.StrEncrypt(string,password,5,1) ; encrypts string using AES_128 encryption and MD5 hash
		if user_key <>
			gosub sub_c_write	; -- does the actual writing to the file the user specified
	}
	if input_pass = 1 	; only execute the line if we're trying to paste a password, else, just log in.
	{
		decrypted_string := Crypt.Encrypt.StrDecrypt(hash,password,5,1)				  ; decrypts the string using previously generated hash,AES_128 and MD5
		Msgbox , You're now logged in`, please try again.
		input_pass = 0
	}
	GUI 11:destroy
return
sub_gui11_quit:
	adding = 0
	GUI 11:destroy
return
; -- writes the command to the file and allows for adding the hotkey without reloading (handy when the user has provided log in details for the password)
sub_c_write:
	ifexist %gui2_selected_custom_file%
	{
		stringreplace , c_name, c_name, | ,, ALL
		stringreplace , c_setpath, c_setpath, | ,, ALL
		stringreplace , c_key, c_key, | ,, ALL
		stringreplace , c_choice, c_choice, | ,, ALL
		FileAppend , `n%c_name%|%c_setpath%|%c_key%|%c_choice%, %gui2_selected_custom_file%
		; empty the GUI?
	}
	adding = 0
return