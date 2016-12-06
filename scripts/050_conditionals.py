import subprocess

def get_tags():
	try:
		p = subprocess.Popen(['/usr/share/google/get_metadata_value','tags'], 
					stdout=subprocess.PIPE, 
					stderr=subprocess.PIPE)
		out, err = p.communicate()
		tags = eval(out.decode("utf-8"))
	except:
		tags = []

	return tags

if __name__ == '__main__':
	tags = get_tags()	

	print("Found tags", tags)

	if 'spacy-download' in tags:
		print("Downloading spacy models")
	    from spacy.en.download import main
	    main()