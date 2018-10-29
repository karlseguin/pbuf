F=
SCHEMA_DIR=test/schemas/
GOOGLE_PROTO_ROOT=/usr/local/include

# generate files necessary using a protoc generator built from this source
gen:
	mix escript.build

	# bootstrap the descriptor model
	# rm -fr lib/protoc/google/
	# protoc -I=${GOOGLE_PROTO_ROOT} -I=. --fast-elixir_out=./lib/protoc/ --plugin=protoc-gen-fast-elixir `find ${GOOGLE_PROTO_ROOT}/google/protobuf -name "*.proto" -not -path "*empty.proto"`

	rm -f ${SCHEMA_DIR}generated/*
	protoc -I=${GOOGLE_PROTO_ROOT} -I=. --elixir_out=. ${SCHEMA_DIR}proto/*.proto
	mv ${SCHEMA_DIR}proto/user.pb.ex ${SCHEMA_DIR}generated/sanity.user.pb.ex
	mv ${SCHEMA_DIR}proto/everything.pb.ex ${SCHEMA_DIR}generated/sanity.everything.pb.ex
	find ${SCHEMA_DIR}generated -name '*.pb.ex' -print0 | xargs -0 sed -i.bak -e 's/Pbuf.Tests./Sanity.Pbuf.Tests./g'
	find ${SCHEMA_DIR}generated -name '*.bak' -delete

	protoc -I=${GOOGLE_PROTO_ROOT} -I=. --fast-elixir_out=. --plugin=protoc-gen-fast-elixir ${SCHEMA_DIR}proto/*.proto
	mv ${SCHEMA_DIR}proto/*.pb.ex ${SCHEMA_DIR}generated/

t:
	mix test ${F}

p:
	rm -fr ./test/schemas/generated/*
	protoc --proto_path=./test/schemas/ \
		--fast-elixir_out=./test/schemas/generated/ \
		`find ./test/schemas -name "*.proto"`

