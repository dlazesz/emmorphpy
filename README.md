# emMorphPy
A wrapper and lemmatizer implemented in Python for ___emMorph__ (Humor) Hungarian morphological analyzer_ 

(A previous version of the code is stored at https://github.com/ppke-nlpg/emmorphpy .)

## Requirements

  - (Included in this repository) The compiled FST (hu.hfstol): go to https://github.com/dlt-rilmta/emMorph for compilation details
  - (Included in this repository) The lemmatizer config file: available at https://github.com/dlt-rilmta/hunlp-GATE/blob/master/Lang_Hungarian/resources/hfst/hfst-wrapper.props
  - _hfst-lookup 0.6 (hfst 3.13.0)_ or higher: On Ubuntu 18.04 LTS or higher just `sudo apt install hfst`
  - Python 3 (>=3.6, tested with 3.6)
  - Pip to install the additional requirements in requirements.txt
  - (Optional) a cloud service like [Heroku](https://heroku.com) for hosting the API

## Features
 - Stemming and returning the detailed morphological analyses with the proper transducer and config file
 - Handling extra and exceptional lexicons statically and dynamically (see [emmorphpy/emmorphpy.py](https://github.com/dlt-rilmta/emmorphpy/blob/master/emmorphpy/emmorphpy.py) for details)
 - Can be used through REST API (using [xtsv](https://github.com/dlt-rilmta/xtsv)), or from Python as a library (see usage examples below)

## Install on local machine

  - Clone the repository
  - Run: `sudo pip3 install -r requirements.txt`
  - Use from Python

## Install to Heroku

__WARNING: Heroku free tier is discontinued.__

  - Register
  - Download Heroku CLI
  - Login to Heroku from the CLI
  - Create an app
  - Clone the repository
  - Add Heroku as remote origin
  - Add APT buildpack: `heroku buildpacks:add --index 1 https://github.com/heroku/heroku-buildpack-apt`
  - Add Python buildpack: `heroku buildpacks:add --index 2 heroku/python`
  - Push the repository to Heroku
  - Enjoy!

## Build docker image and run as container

  - `docker build . -t emmorphRESTAPI`
  - `docker run -p8000:80 emmorphRESTAPI`
  - Rest API is running on: http://localhost
  - To use with https://render.com one must define the environment variable `PORT` to `8000`

## Usage

  - From browser or anyhow through the REST API:
     - Lemmatization: https://emmorph.onrender.com/stem/működik
     - Detailed analysis: https://emmorph.onrender.com/analyze/működik
     - Lemmatisation with the corresponding detailed analysis: https://emmorph.onrender.com/dstem/működik
     - The library also support HTTP POST requests to handle multiple words at once. (See examples for details.)

	```python
	>>> import requests
	>>> import json
	>>> word = 'működik'
	>>> json.loads(requests.get('https://emmorph.onrender.com/stem/' + word).text)[word]
	[{'lemma': 'működik', 'tag': '[/V][Prs.Def.3Pl]'}, {'lemma': 'működik', 'tag': '[/V][Prs.NDef.3Sg]'}]
	>>> json.loads(requests.get('https://emmorph.onrender.com/analyze/' + word).text)[word]
	[{'morphana': 'működik[/V]=működ+ik[Prs.Def.3Pl]=ik'}, {'morphana': 'működik[/V]=működ+ik[Prs.NDef.3Sg]=ik'}]
	>>> json.loads(requests.get('https://emmorph.onrender.com/dstem/' + word).text)[word]
    [{'lemma': 'működik', 'tag': '[/V][Prs.Def.3Pl]', 'morphana': 'működik[/V]=működ+ik[Prs.Def.3Pl]=ik', 'readable': 'működik[/V]=működ + ik[Prs.Def.3Pl]', 'twolevel': 'm:m ű:ű k:k ö:ö d:d :i :k :[/V] i:i k:k :[Prs.Def.3Pl]'}, {'lemma': 'működik', 'tag': '[/V][Prs.NDef.3Sg]', 'morphana': 'működik[/V]=működ+ik[Prs.NDef.3Sg]=ik', 'readable': 'működik[/V]=működ + ik[Prs.NDef.3Sg]', 'twolevel': 'm:m ű:ű k:k ö:ö d:d :i :k :[/V] i:i k:k :[Prs.NDef.3Sg]'}]
	>>> words = '\n'.join(('form', word, 'word2', ''))  # One word per line (first line is header, trailing newline is needed!)
	>>> words_out = requests.post('https://emmorph.onrender.com/stem', files={'file': words}).text.split('\n')
	>>> print(words_out[1].split('\t'))
	['működik', '[{"lemma": "működik", "tag": "[/V][Prs.Def.3Pl]"}, {"lemma": "működik", "tag": "[/V][Prs.NDef.3Sg]"}]']
	>>> words_out = requests.post('https://emmorph.onrender.com/analyze', files={'file': words}).text.split('\n')
	>>> print(words_out[1].split('\t'))
	['működik', '[{"morphana": "működik[/V]=működ+ik[Prs.Def.3Pl]=ik"}, {"morphana": "működik[/V]=működ+ik[Prs.NDef.3Sg]=ik"}]']
    >>> words_out = requests.post('https://emmorph.onrender.com/dstem', files={'file': words}).text.split('\n')
	>>> print(words_out[1].split('\t'))
	['működik', '[{"lemma": "működik", "tag": "[/V][Prs.Def.3Pl]", "morphana": "működik[/V]=működ+ik[Prs.Def.3Pl]=ik", "readable": "működik[/V]=működ + ik[Prs.Def.3Pl]", "twolevel": "m:m ű:ű k:k ö:ö d:d :i :k :[/V] i:i k:k :[Prs.Def.3Pl]"}, {"lemma": "működik", "tag": "[/V][Prs.NDef.3Sg]", "morphana": "működik[/V]=működ+ik[Prs.NDef.3Sg]=ik", "readable": "működik[/V]=működ + ik[Prs.NDef.3Sg]", "twolevel": "m:m ű:ű k:k ö:ö d:d :i :k :[/V] i:i k:k :[Prs.NDef.3Sg]"}]']
	```
 
  - From Python:

	```python
	>>> from emmorphpy import EmMorphPy
	>>> m = EmMorphPy()
	>>> m.stem('működik')     # Returns list of lemmatisations (stem and tag pairs)
	[('működik', '[/V][Prs.Def.3Pl]'), ('működik', '[/V][Prs.NDef.3Sg]')]
	>>> m.analyze('működik')  # Returns list of detailed analyzes (word by morphemes)
	['működik[/V]=működ+ik[Prs.Def.3Pl]=ik', 'működik[/V]=működ+ik[Prs.NDef.3Sg]=ik']
	>>> m.dstem('működik')    # Returns list of lemmatisations with the corresponding detailed analyzes (stem, tag and detailed analyzes triples)
	[('működik', '[/V][Prs.Def.3Pl]', 'működik[/V]=működ+ik[Prs.Def.3Pl]=ik', 'működik[/V]=működ + ik[Prs.Def.3Pl]', 'm:m ű:ű k:k ö:ö d:d :i :k :[/V] i:i k:k :[Prs.Def.3Pl]'), ('működik', '[/V][Prs.NDef.3Sg]', 'működik[/V]=működ+ik[Prs.NDef.3Sg]=ik', 'működik[/V]=működ + ik[Prs.NDef.3Sg]', 'm:m ű:ű k:k ö:ö d:d :i :k :[/V] i:i k:k :[Prs.NDef.3Sg]')]
	>>> # Add new analyses to the lexicon (Not a paradigm, but a single analysis!) Format: [('STEM', 'TAG', 'DETAILED_ANALYSIS', 'HFST-OUTPUT')]
	>>> m.lexicon['Obamával'] = [('Obama', '[/N][Nom]', '', ''), ('Obam', '[/N][Nom]', '', ''), ('Obamá', '[/N][Nom]', '', '')]
	>>> # Add new exceptions to the lexicon (Exact matches will be filtered out ASAP!) Format: ('HFST-OUTPUT')
	>>> m.exceptions['almával'] = {'a:a l:l :o m:m :[/N] á:a :[Poss.3Sg] v:v a:a l:l :[Ins]'}  
	```
 
 - From CLI:

	```bash
	$ python3 -m emmorphpy --raw  # Interactive mode (currently dstem mode only)
	Type one word per line, Ctrl+D or empty word to exit
	--> működik
	[('működik', '[/V][Prs.Def.3Pl]', 'működik[/V]=működ+ik[Prs.Def.3Pl]=ik', 'működik[/V]=működ + ik[Prs.Def.3Pl]', 'm:m ű:ű k:k ö:ö d:d :i :k :[/V] i:i k:k :[Prs.Def.3Pl]'), ('működik', '[/V][Prs.NDef.3Sg]', 'működik[/V]=működ+ik[Prs.NDef.3Sg]=ik', 'működik[/V]=működ + ik[Prs.NDef.3Sg]', 'm:m ű:ű k:k ö:ö d:d :i :k :[/V] i:i k:k :[Prs.NDef.3Sg]')]
	$ python3 -m emmorphpy --raw -i input.txt  # Batch mode
	működik	működik[/V]=működ+ik[Prs.Def.3Pl]=ik	működik	[/V][Prs.Def.3Pl]
	működik	működik[/V]=működ+ik[Prs.NDef.3Sg]=ik	működik	[/V][Prs.NDef.3Sg]
	
	a	a[/Det|Art.Def]=a	a	[/Det|Art.Def]
	a	a[/Det|Pro|(Post)]=a	a	[/Det|Pro|(Post)]
	a	a[/N|Ltr]=a+[Nom]=	a	[/N][Nom]
	a	a[/N|Pro|(Post)]=a+[Nom]=	a	[/N|Pro|(Post)][Nom]
	
	program	program[/N]=program+[Nom]=	program	[/N][Nom]

	```

## License

This Python wrapper, the lemmatizer implementation is licensed under the LGPL 3.0 license.
xtsv, HFST, the database and the lemmatizer configuration has their own license.
