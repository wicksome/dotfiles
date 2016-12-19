# atom-runner issue
# https://github.com/steelbrain/linter/issues/150#issuecomment-99426665    
process.env.PATH = ["/usr/bin",
					"/usr/local/bin",
					process.env.PATH].join(":")
