-- Q44 is a multi-choice question (4 statements), the importer made it numeric because the answer is one digit.
update questions set type = 'coxlu_secim'::question_type where code = 'KT1-S22-Q044';
select code, type, correct_answer from questions where code = 'KT1-S22-Q044';
