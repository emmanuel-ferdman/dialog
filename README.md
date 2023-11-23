# Dialog

Humanized Conversation API (using LLM)

> conversations in a human way without exposing that it's a LLM answering

## Settings

To use this project, you need to have a `.csv` file with the knowledge base and a `.toml` file with your prompt configuration.

We recommend that you create a folder inside this project called `data` and put CSVs and TOMLs files over there.

### `.csv` knowledge base

**fields:**

- category
- subcategory: used to customize the prompt for specific questions
- question
- content: used to generate the embedding

**example:**

```csv
category,subcategory,question,content
faq,promotions,loyalty-program,"The company XYZ has a loyalty program when you refer new customers you get a discount on your next purchase, ..."
```

### `.toml` prompt configuration

The `[prompt.header]`, `[prompt.suggested]`, and `[fallback.prompt]` fields are mandatory fields used for processing the conversation and connecting to the LLM.

The `[fallback.prompt]` field is used when the LLM does not find a compatible embedding on the database, without it, it would hallucinate on possible answers for questions outside of the scope of the embeddings.

It is also possible to add information to the prompt for subcategories, see below for an example of a complete configuration:

```toml
[prompt]
header = """You are a service operator called Avelino from XYZ, you are an expert in providing
qualified service to high-end customers. Be brief in your answers, without being long-winded
and objective in your responses. Never say that you are a model (AI), always answer as Avelino.
Be polite and friendly!"""

suggested = "Here is some possible content that could help the user in a better way."

[prompt.subcategory.loyalty-program]

header = """The client is interested in the loyalty program, and needs to be responded to in a
salesy way; the loyalty program is our growth strategy."""

[fallback]
prompt = """I'm sorry, I didn't understand your question. Could you rephrase it?"""
```

### Environment Variables

Look at the [`.env.sample`](.env.sample) file to see the environment variables needed to run the project.

## Run the project

> we assume you are familiar with [Docker](https://www.docker.com/)

```bash
cp .env.example .env # edit the .env file, add the OPENAI token and the path to the .csv and .toml files
docker compose up
```

After uploading the project, go to the documentation `http://localhost:8000/docs` to see the API documentation.

### Docker

The **dialog** docker image is distributed in [GitHub Container Registry](https://github.com/orgs/talkdai/packages/container/package/dialog) with the tag `latest`.

**image:** `docker pull ghcr.io/talkdai/dialog:latest`

### local development

We've used Python and bundled packages with `poetry`, now it's up to you - ⚠️ we're not yet at the point of explaining in depth how to develop and contribute, [`Makefile`](Makefile) may help you.

#### Creating new/altering tables or columns

If you need to create new tables or columns, you need to run the following command:

```bash
docker compose exec web alembic revision --autogenerate
```

Then, with the generated file already modified with the operations you would like to perform, run the following command:

```bash
docker compose exec web alembic upgrade head
```

In order to the newly created table become available in SQLAlchemy, you need to add the following lines to the file `src/models/__init__.py`:

```python
class TableNameInSingular(Base):
    __table__ = Table(
        "your_db_table_name",
        Base.metadata,
        psql_autoload=True,
        autoload_with=engine,
        extend_existing=True
    )
    __tablename__ = "your_db_table_name"
```