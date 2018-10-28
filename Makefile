F=
SCHEMA_DIR=test/schemas/

# generate files necessary using a protoc generator built from this source
gen:
	rm ${SCHEMA_DIR}generated/*
	protoc --elixir_out=. ${SCHEMA_DIR}proto/*.proto
	mv ${SCHEMA_DIR}proto/user.pb.ex ${SCHEMA_DIR}generated/sanity.user.pb.ex
	mv ${SCHEMA_DIR}proto/everything.pb.ex ${SCHEMA_DIR}generated/sanity.everything.pb.ex
	find ${SCHEMA_DIR}generated -name '*.pb.ex' -print0 | xargs -0 sed -i.bak -e 's/Pbuf.Tests./Sanity.Pbuf.Tests./g'
	find ${SCHEMA_DIR}generated -name '*.bak' -delete

	mix escript.build
	protoc --fast-elixir_out=. --plugin=protoc-gen-fast-elixir ${SCHEMA_DIR}proto/*.proto
	mv ${SCHEMA_DIR}proto/user.pb.ex ${SCHEMA_DIR}generated/user.pb.ex
	mv ${SCHEMA_DIR}proto/everything.pb.ex ${SCHEMA_DIR}generated/everything.pb.ex

t:
	mix test ${F}

p:
	rm -fr ./test/schemas/generated/*
	protoc --proto_path=./test/schemas/ \
		--fast-elixir_out=./test/schemas/generated/ \
		`find ./test/schemas -name "*.proto"`

