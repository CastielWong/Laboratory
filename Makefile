
dir_script = ./dev/script


worktree:
	bash ${dir_script}/set_worktree.sh $(feature)

tag:
	bash ${dir_script}/tag_feature.sh $(poc) $(desc)

clean-up:
	git branch -d feature/$(feature)
	bash ${dir_script}/clean_worktree.sh $(feature)
