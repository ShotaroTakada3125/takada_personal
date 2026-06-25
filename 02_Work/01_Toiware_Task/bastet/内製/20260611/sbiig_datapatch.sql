select * from stockholder_bonus_entry where stockholder_bonus_master_id = (
select id from stockholder_bonus_master where title = 'SBIインシュアランスグループ株主優待 (2026年6月分)');


update stockholder_bonus_entry set delete_flag = true where stockholder_bonus_master_id = (
select id from stockholder_bonus_master where title = 'SBIインシュアランスグループ株主優待 (2026年6月分)');


delete from stockholder_bonus_entry where stockholder_bonus_master_id = (
select id from stockholder_bonus_master where title = 'SBIインシュアランスグループ株主優待 (2026年6月分)');