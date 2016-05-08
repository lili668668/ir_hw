* init
set safety off

* main
select doc_id, count(bigram) as tf, bigram from bigram group by doc_id, bigram into table tf
select doc_id, bigram, max(tf) as tf from tf group by doc_id into table max_tf
select tf.doc_id, tf.bigram, tf.tf, (tf.tf/max_tf.tf) as tf_norm where tf.doc_id=max_tf.doc_id from tf, max_tf into table tf_normalize

* exit
close all
return
