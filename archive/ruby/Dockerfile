# FROM public.ecr.aws/lambda/ruby:2.7

# RUN yum groupinstall -y "Development Tools" \
#     && yum install -y which openssl

# RUN yum install -y git make gcc bzip2 openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel tar gzip && \
#   git clone https://github.com/rbenv/ruby-build.git && \
#   PREFIX=/usr/local ./ruby-build/install.sh

# RUN  curl -L "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE" -o mecab-0.996.tar.gz \
#     && tar xzf mecab-0.996.tar.gz \
#     && cd mecab-0.996 \
#     && ./configure --build=arm-linux --with-charset=utf8\
#     && make \
#     && make check \
#     && make install \
#     && cd .. \
#     && rm -rf mecab-0.996*

# RUN curl -L "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7MWVlSDBCSXZMTXM" -o mecab-ipadic-2.7.0-20070801.tar.gz \
#     && tar -zxvf mecab-ipadic-2.7.0-20070801.tar.gz \
#     && cd mecab-ipadic-2.7.0-20070801 \
#     && ./configure --build=arm-linux --with-charset=utf8\
#     && make \
#     && make install \
#     && cd .. \
#     && rm -rf mecab-ipadic-2.7.0-20070801

# Copy function code
# COPY . ${LAMBDA_TASK_ROOT}

# Install dependencies under LAMBDA_TASK_ROOT
# ENV GEM_HOME=${LAMBDA_TASK_ROOT}
# RUN bundle install

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
#CMD [ "src/tweet.LambdaFunction::Handler.process" ]
#CMD [ "src/remove.LambdaFunction::Handler.process" ]
# CMD [ "src/reply.LambdaFunction::Handler.process" ]


FROM ubuntu:latest

RUN yum install -y git make gcc bzip2 openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel tar gzip && \
  git clone https://github.com/rbenv/ruby-build.git && \
  PREFIX=/usr/local ./ruby-build/install.sh

RUN  curl -L "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE" -o mecab-0.996.tar.gz \
    && tar xzf mecab-0.996.tar.gz \
    && cd mecab-0.996 \
    && ./configure --build=arm-linux --with-charset=utf8\
    && make \
    && make check \
    && make install \
    && cd .. \
    && rm -rf mecab-0.996*

RUN curl -L "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7MWVlSDBCSXZMTXM" -o mecab-ipadic-2.7.0-20070801.tar.gz \
    && tar -zxvf mecab-ipadic-2.7.0-20070801.tar.gz \
    && cd mecab-ipadic-2.7.0-20070801 \
    && ./configure --build=arm-linux --with-charset=utf8\
    && make \
    && make install \
    && cd .. \
    && rm -rf mecab-ipadic-2.7.0-20070801
