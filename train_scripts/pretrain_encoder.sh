CHUNK_SIZE=32  #32 stands for 320ms

CVSS_ROOT=path_to_your_data
CHECKPOINT_DIR=path_to_save_your_checkpoint
NAST_DIR=path_to_nast_dir

fairseq-train ${CVSS_ROOT} \
    --config-yaml config.yaml --train-subset train --valid-subset dev \
    --user-dir ${NAST_DIR} \
    --fp16 \
    --task nat_speech_to_text_ctc_modified --arch nonautoregressive_streaming_speech_transformer_segment_to_segment \
    --src-embedding-copy --max-source-positions 6000 --max-target-positions 1024 \
    --src-upsample-ratio 1 --main-context ${CHUNK_SIZE} --right-context ${CHUNK_SIZE} --unit-size 2 \
    --share-decoder-input-output-embed --rand-pos-encoder 300 --decoder-learned-pos \
    --activation-dropout 0.1 --attention-dropout 0.1 \
    --encoder-max-relative-position 32 \
    --apply-bert-init --noise full_mask \
    --criterion nat_loss_ngram_glat_asr --glat-p 0.5:0.3@50k \
    --label-smoothing 0.01 --dropout 0.3 --weight-decay 0.01 --clip-norm 10.0 \
    --optimizer adam --adam-betas '(0.9,0.98)' \
    --lr 0.001 --lr-scheduler inverse_sqrt \
    --warmup-init-lr '1e-07' --warmup-updates 10000 \
    --stop-min-lr '1e-09' --max-update 150000 \
    --max-tokens 40000 --update-freq 4 --grouped-shuffling \
    --save-dir ${CHECKPOINT_DIR} \
    --ddp-backend=legacy_ddp \
    --no-progress-bar --log-format json --log-interval 100 \
    --save-interval-updates 2000 --keep-interval-updates 10 \
    --save-interval 1000 --keep-last-epochs 10 \
    --fixed-validation-seed 7 \
    --skip-invalid-size-inputs-valid-test \
    --validate-interval 1000 --validate-interval-updates 2000 \
    --eval-bleu --eval-bleu-args '{"iter_decode_max_iter": 0, "iter_decode_with_beam": 1}' \
    --eval-bleu-print-samples \
    --num-workers 8
