# Weilue Luo's CV

## Links
> [English Version](https://github.com/Redcxx/cv/blob/master/resume.pdf) (usually more up-to-date) 

## Preview
![resume preview](./src/resume.png)

## Compliation
```bash
git clone https://github.com/Redcxx/cv.git
cd cv/src

sudo apt-get update
sudo apt-get install texlive-full
sudo apt-get install texlive-fonts-extra

lualatex resume.tex
```

### Generating available fonts
```
mtxrun --script fonts --list --all >> fonts.txt
```


### GPT Prompts for translating to chinese
```
I want you to act as a an expert in latex, chinese and english, I will give you my english latex file, it may use macro/functions from another file, do not change those, instead translate the words to chinese, please remember that this a resume, your translation should written in a professional way that is appealing to recruiters
```

## Contributing
Feel free to open an issue :D
