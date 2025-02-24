# Datathon-2025-Group-43

## Steam Game Owner Predictor
Our model is trained to take information about steam games, the expected play time, number of acheivements, number of languages, tags .... And convert it into a range of expected owners:|0 - 20,000 | 20,000 - 200,000|  ... 

The data was obtained via two different Kaggle data sets https://www.kaggle.com/datasets/vicentearce/steam-and-steam-spy-raw-datasets, https://www.kaggle.com/datasets/joebeachcapital/top-1000-steam-games ,then linked up, and cleaned in a combination of R and Stata files, and then passed off for multiple model fitting.
Two Random Forest analysis (one in Stata one in Python) and Two MLPs (One TensorFlow one in Pytorch) were conducted with similar output results.

The final model was then embedded into a server where a user can select the game perameters and ask the model to output the expected number of players.
All output graphs are shown in the presentation along with a demonstration of the website.

Youtube Link:
https://youtu.be/Tsz4kWWl-VI

Slide Link
https://www.canva.com/design/DAGf9DN8JcI/JmfhB802J0LQ4i7sG8ZNYw/edit?utm_content=DAGf9DN8JcI&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton
